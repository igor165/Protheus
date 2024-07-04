#Include "EEC.cH"
#Include "EECAE109.CH"
/*
Programa        : EECAE109.PRW
Objetivo        : Rotinas de Wash - Out
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 02/12/05 - 08:30
Obs.            : 
*/
                                      
#xTranslate SumTotal() => Eval(bTotal,"SOMA")
#xTranslate SubTotal() => Eval(bTotal,"SUBTRAI")


/*
Funcao      : EECFilterEmb()
Parametros  : cNmRotina -> 
Retorno     : Nil
Objetivos   : Filtrar a tabela de capa dos Embarques.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 02/12/05 - 08:30
Revisao     :
Obs.        :
*/
*-------------------------------*
Function EECFilterEmb(cNmRotina)
*-------------------------------*
Local cFiltro

If Len(EEC->(DbFilter())) > 0
   EEC->(DbClearFilter())
EndIf

Do Case
   Case cNmRotina == "WASHOUT"
      cFiltro := "EEC_TIPO == 'W'"
      
   Case cNmRotina == "EMBARQUE"
      cFiltro := "EEC_TIPO <> 'W'"
   
   Case cNmRotina == "WASHOUT-RV"
      cFiltro := "EEC_TIPO == 'W'"
      
End Case

If ValType(cFiltro) == "C"
   EEC->(dbSetFilter(&("{|| " + cFiltro + " }"), cFiltro))
EndIf

Return Nil


/*
Funcao      : AE109WASHOUT()
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Executar mBrowse
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 02/12/05 - 15:00
Revisao     :
Obs.        :
*/
*---------------------*
Function AE109WashOut()
*---------------------*

Private aRotina := MenuDef(ProcName())
Private aMemos := {{"EEC_CODMEM","EEC_OBS"}}

Private aMemoItem := {{"EE9_DESC"  ,"EE9_VM_DES"},;
                      {"EE9_QUADES","EE9_DSCQUA"}}

Private bTotal := {|x| x := if(x=="SOMA",1,-1),;
                      M->EEC_PESLIQ += x*If(lConvUnid,AvTransUnid(WorkIp->EE9_UNPES,M->EEC_UNIDAD,WorkIp->EE9_COD_I,WorkIp->EE9_PSLQTO,.F.),WorkIp->EE9_PSLQTO),;
                      M->EEC_PESBRU += x*If(lConvUnid,AvTransUnid(WorkIp->EE9_UNPES,M->EEC_UNIDAD,WorkIp->EE9_COD_I,WorkIp->EE9_PSBRTO,.F.),WorkIp->EE9_PSBRTO),;
                      M->EEC_TOTPED += x*WorkIP->EE9_PRCINC,;
                      M->EEC_TOTITE += x*1,;
                      AE100TTela(.F.)}

Private cNomArq1, cNomArq2, cNomArq3, cNomArq4, cNomArq5, cNomArq6, cNomArq7, cNomArq8, cNomArq9, cNomArq10,;
        cNomArq11, cNomArq12, cNomArq13, cNomArq14, cNomArq17 // By JPP 11/12/2006 - 16:00

// Cria variaveis para Notify's.
Private aNoEnchoice, aNoPos, aNoBrowse

// Cria variaveis para agentes/empresas.
Private aAgEnchoice, aAgPos, aAgBrowse

// Cria variaveis para Depesas.
Private aDeEnchoice, aDePos, aDeBrowse 

// Cria variaveis para instituicoes
Private aInEnchoice, aInPos, aInBrowse

Private lIntegracao := IsIntFat(), lIntCont  := .F.

Private lConvUnid := .F., lLibPes := .F.   

Private cFilBr := "", cFilEx := ""

Private lIntermed := EECFlags("INTERMED")

Private aWkChRecno := {}
Private aWorks := {}
Private cStatus := ST_WA
Private cTipoProc := PC_RG
Private cArqWkEYU, aCampoEYU, lItFabric := .F., aItFabPos, aEYUDel,nRegFabrIt
Private lIntDesp := .F.

Private aConsolida := {}

Private lOkEstor:= SX3->(dbSeek("ECF_PREEMB")) .And. SX3->(dbSeek("ECF_FASE")) .And. SX3->(dbSeek("ECF_PREEMB")) .And. ;
			       SX3->(dbSeek("EEQ_FASE")) .And. SX3->(dbSeek("EEQ_EVENT")) .And. SX3->(dbSeek("EEQ_NR_CON")) .And. ;
			       SX3->(dbSeek("EET_DTDEMB"))

Begin Sequence
   
   If !lIntermed .Or. (xFilial("EEC") <> cFilEx)
      // ** Disponibiliza a opção de Wash-Out somente na filial de off-shore.
      MsgInfo(STR0024,STR0052)//"A manutenção de Wash-Out de contrato deverá ser realizada somente a partir da filial de Off-Shore." ### "Aviso"
      Break
   EndIf

   //Cria Arquivos Temporários
   Ae109Defs("WORKS")
   AE109Works("CREATE",aWorks)
      
   //Filtra a tabela EEC para mostrar somente os Embarques de Wash-Out
   EECFilterEmb("WASHOUT")
   
   SetMbrowse("EEC")
   
End Sequence

AE109Works("ERASE",aWorks) //Apaga os Arquivos Temporários
//Apaga o Filtro
EECFilterEmb()

Return Nil     



/*
Funcao     : MenuDef()
Parametros : cOrigem
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya	
Data/Hora  : 05/02/07 - 14:21
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina := {}
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))

Begin Sequence

   Do Case
      
      Case cOrigem $ "AE109WASHOUT"  //Wash-Out
           aAdd( aRotina, { STR0002, "AxPesqui" , 0 , 1} ) //"Pesquisar "
           aAdd( aRotina, { STR0001, "AE109MAN" , 0 , 2} ) //"Visualizar"
           aAdd( aRotina, { STR0003, "AE109MAN" , 0 , 3} ) //"Incluir"
           aAdd( aRotina, { STR0004, "AE109MAN" , 0 , 4} ) //"Alterar"
           aAdd( aRotina, { STR0005, "AE109MAN" , 0 , 5,3})//"Excluir"

           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("EAE109WMNU")
      	      aRotAdic := ExecBlock("EAE109WMNU",.f.,.f.)
       	      If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf
           
      Case cOrigem $ "AE109RVWASHOUT"   //Wash-Out RV
           aAdd( aRotina, { STR0002, "AxPesqui" , 0 , 1} )//"Pesquisar "
           aAdd( aRotina, { STR0001, "AE109MAN" , 0 , 2} )  //"Visualizar"
           aAdd( aRotina, { STR0003, "AE109MAN" , 0 , 3} ) //"Incluir"
           aAdd( aRotina, { STR0004, "AE109MAN" , 0 , 4} )  //"Alterar"
           aAdd( aRotina, { STR0005, "AE109MAN" , 0 , 5,3}) //"Excluir"
          
           // P.E. utilizado para adicionar itens no Menu da mBrowse
           If EasyEntryPoint("EAE109RWMNU")
      	      aRotAdic := ExecBlock("EAE109RWMNU",.f.,.f.)
       	      If ValType(aRotAdic) == "A"
		         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	          EndIf
           EndIf

   End Case 
      
End Sequence

Return aRotina

/*
Funcao      : Ae109TipoWO()
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Permite que o usuário informe o tipo de Wash-Out a ser realizado.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*---------------------*
Function Ae109TipoWO()
*---------------------*

Local bOk     := {|| If(Eval(bValid),(lRet := .T., oDlg:End()),)} 
Local bCancel := {|| oDlg:End() }  
Local bValid  := {|| If(!Empty(cTipo),.T.,(MsgInfo(STR0006,STR0051),.F.)) } //"Favor informar o tipo de Wash-Out." ### "Alerta"
Local oDlg
Local lRet := .F.
Local aTipos := {"In","Out","Nothing"}
Local cTipo := Space(7)

DEFINE MSDIALOG oDlg TITLE STR0007 FROM 331,360 TO 415,600 OF oMainWnd PIXEL //"Wash-Out Contrato"
 nBorda1 := (oDlg:nClientHeight - 2.5)/2   
 nBorda2 := (oDlg:nClientWidth - 2.5)/2
 oDlg:lEscClose := .F.

 @ 14,2 To nBorda1, nBorda2 Label STR0009 Pixel //"Tipo de Wash-Out:"
 @ 22,6 ComboBox oCombo Var cTipo Items aTipos Size 110,07 Pixel Of oDlg

Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered

   If lRet
      //Define o Status conforme o tipo de Wash-Out escolhido
      If cTipo == aTipos[1]
         M->EXL_TIPOWO := ST_WI
      ElseIf cTipo == aTipos[2]
         M->EXL_TIPOWO := ST_WO
      ElseIf cTipo == aTipos[3]
         M->EXL_TIPOWO := ST_WN
      EndIf
      M->EEC_STATUS := M->EXL_TIPOWO
      M->EEC_STTDES := Tabela("YC", M->EEC_STATUS)
   EndIf

Return lRet

/*
Funcao      : AE109MAN()
Parametros  : cAlias, nReg, nOpc
Retorno     : Nenhum.
Objetivos   : Efetuar manutenção em um contrato de Wash-Out.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 13:00
Revisao     :
Obs.        :
*/
*----------------------------------*
Function AE109MAN(cAlias,nReg,nOpc)
*----------------------------------*
Local aOrd:=SaveOrd("EEC")
Local bCancel := {|| oDlg:End() }
Local bOk     := {|| If((Ae109Valid("VAL_OK")),(oDlg:End(), lOk := .T.),) }
Local lInverte := .f., i, x
Local aPosEnc, aPosSel
Local aButtons := {}
Local lOk := .F.
Local oDlg
Local cFilAux := xFilial("EEC"), j:=0
Private oMsSelect
Private lAltera := .F., lSITUACAO:=.T., LSLCAMB := .T., LCAMBIO := .T.
Private oSbox
Private aTela[0][0],aGets[0]
Private cMarca := GetMark()

Private aCpos := {}

Private aItemEnchoice := {}

Private aItemBrowse := {}

Private aObrigatorios := {}
               
Private aHeader:={}

Private nSelecao := nOpc

Private aAgDeletados:={}, aInDeletados:={}, aDeDeletados:={}, aNoDeletados:={}, aDeletados := {}

Private lWhen 

//Invoices
Private cArqCapInv
Private aInvEnchoice, aInvBrowse
Private cArqDetInv,cArq2DetInv
Private aDetInvBrowse
Private aDetInvEnchoice,aAltDetInv
Private aCInvDeletados := {}
Private aDInvDeletados := {}
Private lRefazRateio   := .F.
//Cria variáveis para uso nas funções do Drawback
Private cFilSYS:=xFilial("SYS")
Private lIntDraw := EasyGParam("MV_EEC_EDC",,.F.) //Verifica se existe a integração com o Módulo SIGAEDC
Private lIntFina := EasyGParam("MV_EEC_EFF",,.F.) //Verifica se existe a integração com o Módulo SIGAEFF
SX3->(DBSETORDER(2))
Private lExistEDD   := SX3->(dbSeek("EDD_FILIAL"))
Private lOkEE9_ATO  := SX3->(dbSeek("EE9_ATOCON"))
Private lYSTPMODU   := SX3->(DBSEEK("YS_TPMODU")) .AND. SX3->(DBSEEK("YS_MOEDA"))
Private lOkYS_PREEMB:= SX3->(dbSeek("YS_PREEMB")) .and. SX3->(dbSeek("YS_INVEXP"))
Private lTemTPMODU := SX3->(DbSeek("ECF_TPMODU"))
Private lBackTo  := .F.
Private lIntegra := .F.
Private lConsolida := .F.
Private lConsolOffShore := .F.
Private lConsign := EECFlags("CONSIGNACAO")
Private lTratComis := EasyGParam("MV_AVG0077",,.F.)

Private cITEPIC:=AVSX3("EEC_TOTITE",AV_PICTURE),;
        cTPEPIC:=AVSX3("EEC_TOTPED",AV_PICTURE),;
        cPLIPIC:=AVSX3("EEC_PESLIQ",AV_PICTURE),;
        cPBRPIC:=AVSX3("EEC_PESBRU",AV_PICTURE)

Private cWHENOD := "",cVIA := "",cWHENSA1 := "",cWHENSA2 := ""
Private lNRotinaLC := .f., lMultiOffShore := .F.  // By JPP - 12/12/2006 - 08:30

Begin Sequence        
  If (!lIntermed .Or. xFilial("EEC") <> cFilEx) .And. cStatus <> ST_WR  // By JPP - 12/12/2006 - 14:00
     // ** Disponibiliza a opção de Wash-Out somente na filial de off-shore.
     MsgInfo(STR0024,STR0052)//"A manutenção de Wash-Out de contrato deverá ser realizada somente a partir da filial de Off-Shore." ### "Aviso"
     Break
  ElseIf lIntermed .And. xFilial("EEC") <> cFilBr .And. cStatus == ST_WR 
     MsgInfo(STR0047,STR0052)//"A Rotina de Wash-Out de R.V. não está disponível para a filial Off-Shore." ### "Aviso"
     Break
  EndIf

 
  AE109Works("ZAP",aWorks) //Limpa os Arquivos Temporários
  Ae109Defs("CAMPOS")
  If cStatus <> ST_WR
     cTitulo := STR0007 //"Wash-Out Contrato"
     //***
     If EECFlags("FRESEGCOM")
        aAdd(aButtons,{"POSCLI",   {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100AGEN(OC_EM, nOpc)) }, STR0026}) //"Agentes de Comissão"
        aAdd(aButtons,{"PRECO",    {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100DespNac(OC_EM, nOpc)) }, STR0027}) //"Despesas Nacionais"
        aAdd(aButtons,{"SIMULACAO",{|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AE100DespInt(nOpc)) }, STR0028}) //"Despesas Internacionais"
     Else
        aAdd(aButtons,{"POSCLI",  {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100AGEN(OC_EM,nOpc)) }, STR0029}) //"Empresas"
        aAdd(aButtons,{"PRECO" ,  {|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), (M->cPESQDESP:=M->EEC_PREEMB, AP100DESP(OC_EM,nOpc)))}, STR0030}) //"Despesas"
     EndIf
     aAdd(aButtons,{"TABPRICE" /*"SALARIOS"*/,{|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100INST(OC_EM,nOpc)) }, STR0031}) //"Instituições Bancárias"
     aAdd(aButtons,{"VENDEDOR",{|| If(Empty(M->EEC_PREEMB), Help(" ",1,"AVG0000020"), AP100Notify(OC_EM,nOpc))},STR0032}) //"Notify's"
     If nOpc == INCLUIR .Or. nOpc == ALTERAR
        aAdd(aButtons,{"BMPINCLUIR" /*"NOVACELULA"*/, {|| If(EMPTY(M->EEC_PREEMB), MsgInfo(STR0033,STR0052), (Ae109DetMan(oMsSelect), oMsSelect:oBrowse:Refresh()))}, STR0034})//"Seleção de Itens" ### "Aviso"
     Else
        aAdd(aButtons, {"RELATORIO" /*"ANALITICO"*/, {|| Ae109MarkIt(VIS_DET) }, STR0001}) //"Visualizar"
     EndIf
     //***
  Else
     cTitulo := STR0021//"Wash-Out R.V."
  EndIf
  
  If nOpc == INCLUIR
     SX3->(DbSetOrder(1))
     SX3->(DbSeek(cAlias))
     //Cria variáveis de memória 
     While SX3->(!Eof() .And. X3_ARQUIVO == cAlias)
        M->&((cAlias)->(SX3->X3_CAMPO)) := CRIAVAR(SX3->X3_CAMPO)
        SX3->(DbSkip())
     EndDo

     If EECFlags("COMPLE_EMB")
        For j := 1 TO EXL->(FCount())
           M->&(EXL->(FieldName(j))) := CriaVar(EXL->(FieldName(j)))
        Next
     EndIf

     SX3->(DbSeek("EXL"))
     While SX3->(!Eof() .And. X3_ARQUIVO == "EXL")
        If SX3->X3_CONTEXT = "V"
           M->&(("EXL")->(SX3->X3_CAMPO)) := CRIAVAR(SX3->X3_CAMPO)
        EndIf
        SX3->(DbSkip())
     EndDo 

     /*
     SX3->(DbSeek("EXL"))
     While SX3->(!Eof() .And. X3_ARQUIVO == "EXL")
        M->&(("EXL")->(SX3->X3_CAMPO)) := CRIAVAR(SX3->X3_CAMPO)
        SX3->(DbSkip())
     EndDo */
     //Cria objetos para serem usados pelas Get´s da Função Ae109Gets()
     For i := 1 To Len(aCpos)
        &("o"+aCpos[i][1]) := 0
     Next
     If cStatus == ST_WR
        M->EE9_PRECO := Criavar("EE9_PRECO")
     EndIf
     M->EEC_TIPO   := "W"
     If cStatus <> ST_WR
        M->EXL_TIPOWO := ST_WA
        M->EEC_STTDES := Tabela("YC", M->(EEC_STATUS := EXL_TIPOWO))
            //Chama tela para informar o número do Processo/RV no qual o embarque será baseado
     ElseIf cStatus == ST_WR .And. !AE109GETNMRV()
        Break
     EndIf
  Else              
     If nOpc == ALTERAR .Or. nOpc == EXCLUIR
        IF ! EEC->(RecLock("EEC",.F.,,.T.)) // By JPP - 20/07/2005 10:15 - Inclusão do quarto parametro.
           Break
        Endif
     EndIf
     SX3->(DbSetOrder(1))
     SX3->(DbSeek(cAlias))
     While SX3->(!Eof() .And. X3_ARQUIVO == cAlias)
        If SX3->X3_CONTEXT <> "V"
           M->&((cAlias)->(SX3->X3_CAMPO)) := (cAlias)->&(SX3->X3_CAMPO)
        Else
           M->&((cAlias)->(SX3->X3_CAMPO)) := CRIAVAR(SX3->X3_CAMPO)
        EndIf
        SX3->(DbSkip())
     EndDo
     EXL->(DbSetOrder(1))
     SX3->(DbSeek("EXL"))
     If EXL->(DbSeek(xFilial("EXL")+M->EEC_PREEMB))
        While SX3->(!Eof() .And. X3_ARQUIVO == "EXL")
           If SX3->X3_CONTEXT <> "V"
              M->&(("EXL")->(SX3->X3_CAMPO)) := ("EXL")->&(SX3->X3_CAMPO)
           Else
              M->&(("EXL")->(SX3->X3_CAMPO)) := CRIAVAR(SX3->X3_CAMPO)
           EndIf
           SX3->(DbSkip())
        EndDo
     Else
        While SX3->(!Eof() .And. X3_ARQUIVO == "EXL")
           M->&(("EXL")->(SX3->X3_CAMPO)) := CRIAVAR(SX3->X3_CAMPO)
           SX3->(DbSkip())
        EndDo
     EndIf
     For x:=1 To Len(aMemos)
        If EEC->(FieldPos(aMemos[x][2])) > 0
           M->&(aMemos[x,2]) := MSMM(EEC->&(aMemos[i,1]),AVSX3(aMemos[i,2],AV_TAMANHO))
        EndIf
     Next
     M->EEC_DTEMBA := M->EEC_DTEFE
     For i := 1 To Len(aCpos)
        &("o"+aCpos[i][1]) := 0
     Next
     If cStatus == ST_WR
        M->EE9_PRECO := Criavar("EE9_PRECO")
     EndIf     
  EndIf

  lWhen := Ae109Valid("WHEN")
  
  If cStatus <> ST_WR
     If nOpc <> INCLUIR
        //Grava na Work de itens os itens do processo para marcação
        MsAguarde({|| MsProcTxt(STR0035), AE109CtGrvWk()},STR0007)//"Obtendo dados do processo." ### "Wash-Out Contrato"
 
        WorkIp->(DbSetOrder(2))
        M->EEC_DSCCOM := EECResCom()
     EndIf
  Else
     MsAguarde({|| MsProcTxt(STR0035), Ae109GrvItWk()},STR0021)//"Obtendo dados do processo." ### "Wash-Out R.V."
     //Atualiza a quantidade do R.V.
     If Empty(M->EEC_DTEMBA)
        AE109ChkRv(M->EEC_PEDREF)
     EndIf
  EndIf
  Ae100PrecoI()
  
  DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI; 
                                        TO DLG_LIN_FIM,DLG_COL_FIM; 
                                        OF oMainWnd PIXEL
   oDlg:lEscClose := .F.
   aPosEnc:= PosDlgUp(oDlg)
   aPosEnc[3] += 15
   aPosSel := PosDlgDown(oDlg)
   aPosSel[1] += 30
   
   //Mostra os itens da Capa
   AE109Gets(oDlg, aPosEnc, aCpos)
   
   //Mostra os detalhes
   If M->EXL_TIPOWO <> ST_WR
      aPosSel[3] -= 26
      aPosInf := aClone(aPosSel)
      aPosInf[1] := aPosSel[3]
      aPosInf[3] := aPosInf[1]+28
     // by CRF - 14/10/2010 - 11:28 
      aItemBrowse := AddCpoUser(aItemBrowse,"EE9","2")
      oMsSelect := MsSelect():New("WorkIp",,,aItemBrowse,,,aPosSel)
      oMsSelect:bAval := {|| Ae109MarkIt(VIS_DET) }
      WorkIp->(DbSetFilter({|| !Empty(WorkIp->WP_FLAG) },"!Empty(WorkIp->WP_FLAG)"))
      WorkIp->(DbAppend())
      WorkIp->(DbDelete())
      WorkIp->(DbGoTop())   
      AE100TTELA(.T.,aPosInf)
   Else
      // by CRF - 14/10/2010 - 11:28 
      aItemBrowse := AddCpoUser(aItemBrowse,"EE9","2")
      oMsSelect := MsSelect():New("WorkRv",,,aItemBrowse,,,aPosSel)
      WorkRv->(DbGoTop())      
   EndIf
   oMsSelect:oBrowse:Refresh()
      
  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
  If !lOk
     If nOpc == ALTERAR .Or. nOpc == EXCLUIR // By JPP - 12/12/2006 10:00
        EEC->(MsUnlock())
     EndIf
     Break
  EndIf
  M->EEC_DTEMBA := M->EEC_DTEFE
  WorkIP->(dbClearFilter())
  EECFilterEmb()
  Processa({|| Ae109Grava(nOpc, M->EXL_TIPOWO)},STR0036, STR0037) //"Wash-Out" ### "Gravando Informações"
  
End Sequence

Return Nil

/*
Funcao      : Ae109Grava
Parametros  : nOpc    -> Indica a opção desejada
              cStatus -> Indica o tipo de Wash-Out (Contrato ou R.V.)
Retorno     : Nenhum.
Objetivos   : Efetua a inclusão/alteração/exclusão do Wash-Out
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*--------------------------------*
Function Ae109Grava(nOpc, cStatus)
*--------------------------------*
Local lRet := .T., nRecnoEEC
Private nCambioWO := Ae109SetCambio(cStatus)

Begin Sequence
   Do Case
      Case cStatus $(ST_WI+ST_WO+ST_WN)
         If nOpc == INCLUIR
            Ae102SetGrvEmb(.T.)
            
            If IsProcOffShore(M->EEC_PEDREF,OC_PE,cFilEx)
               nRecnoEEC := EEC->(Recno())
               cFilOld  := AvGetM0Fil()
               cFilAnt  := cFilbr
               M->EEC_PREEMB := M->EXL_WOEMB
               M->EXL_PREEMB := M->EXL_WOEMB
               M->EEC_STATUS := ST_PC
               M->EEC_STTDES := Tabela("YC", M->EEC_STATUS)
               M->EEC_TIPO   := Space(1)
               M->EEC_INTERM := "2"
               Ae102SetGrvEmb(.T.)
               cFilAnt  := cFilOld
               EEC->(DbGoTo(nRecnoEEC))
            EndIf
            Ae109RestSaldo(.F.)
     
         ElseIf nOpc == ALTERAR
            nRecnoEEC := EEC->(Recno())
            ae102SetGrvEmb(.F.)  
            EEC->(MSUnlock()) // By JPP - 12/12/2006 - 09:00

            EEC->(DbGoTo(nRecnoEEC))
            // Ae100Unlock()  // By JPP - 12/12/2006 - 09:00

            If IsProcOffShore(M->EEC_PEDREF,OC_PE,cFilEx)
               cFilOld  := AvGetM0Fil()
               cFilAnt  := cFilbr           
               cPreembOld := M->EEC_PREEMB
               M->EEC_PREEMB := M->EXL_WOEMB
               M->EXL_PREEMB := M->EXL_WOEMB
               M->EEC_TIPO   := Space(1)
               EEC->(DbSetOrder(1))
               EEC->(DbSeek(cFilAnt+M->EEC_PREEMB))
               M->EEC_STATUS := ST_PC
               M->EEC_STTDES := Tabela("YC", M->EEC_STATUS)
               M->EEC_INTERM := "2"     

               nRecnoEE9 := EE9->(Recno())
               //Atualiza os Recnos armazenados nas Works para a Filial oposta
               aWkChRecno :=  Ae109ChangeRecno(aWkChRecno)

               Ae102SetGrvEmb(.F.) 
               // Ae100Unlock()  // By JPP - 12/12/2006 - 09:00
               EEC->(MSUnlock()) // By JPP - 12/12/2006 - 09:00
               EEC->(DbGoTo(nRecnoEEC))
               cFilAnt  := cFilOld     

               //Atualiza os Recnos armazenados nas Works para a Filial original
               aWkChRecno :=  Ae109ChangeRecno(aWkChRecno)

               EE9->(DbGoTo(nRecnoEE9))
            EndIf   
            Ae109RestSaldo(.F.)

         ElseIf nOpc == EXCLUIR
       
            nRecnoEEC := EEC->(Recno())
            AE100DelEmb(.F.,.F.,.F.,.F.)

            EEC->(DbGoTo(nRecnoEEC))
            // Ae100Unlock() // By JPP - 12/12/2006 - 09:00                                   
            EEC->(MSUnlock()) // By JPP - 12/12/2006 - 09:00                                    

            If IsProcOffShore(M->EEC_PEDREF,OC_PE,cFilEx) 
               cFilOld  := AvGetM0Fil()
               cFilAnt  := cFilbr
               M->EEC_PREEMB := M->EXL_WOEMB
               M->EXL_PREEMB := M->EXL_WOEMB
               M->EEC_TIPO   := Space(1)            
               EEC->(DbSetOrder(1))
               EEC->(DbSeek(cFilAnt+M->EEC_PREEMB))
            
               //Atualiza os Recnos armazenados nas Works para a Filial oposta
               aWkChRecno :=  Ae109ChangeRecno(aWkChRecno)

               AE100DelEmb(.T.,.F.,.F.,.F.)
               //Ae100Unlock() // By JPP - 12/12/2006 - 09:00                                                                                                        
               EEC->(MSUnlock()) // By JPP - 12/12/2006 - 09:00                                    
               EEC->(DbGoTo(nRecnoEEC))
               cFilAnt  := cFilOld     
            
               //Atualiza os Recnos armazenados nas Works para a Filial original
               aWkChRecno :=  Ae109ChangeRecno(aWkChRecno)
            EndIf
            Ae109RestSaldo(.T.)
         EndIf
            
      Case cStatus == ST_WR
         If nOpc == INCLUIR
            Ae109EstItRv(M->EEC_PEDREF)
            M->EEC_INTERM := "2"
            Ae102SetGrvEmb(.T.)
      
         ElseIf nOpc == ALTERAR
            Ae109EstItRv(M->EEC_PEDREF)
            Ae102SetGrvEmb(.F.)
                     
         ElseIf nOpc == EXCLUIR
            Ae100DelEmb(.T.,.F.,!Empty(EEC->EEC_DTEMBA),.F.)
         EndIf

   EndCase

End Sequence

If(cStatus <> ST_WR, EECFilterEmb("WASHOUT"), EECFilterEmb("WASHOUT-RV"))
 
Return lRet

/*
Funcao      : Ae109SetCambio
Parametros  : cStatus -> Indica o tipo de Wash-Out
Retorno     : nTot -> Total do embarque a ser considerado pela rotina de cambio, considerando o tipo de Wash-Out.
Objetivos   : Determinar o valor no qual a rotina de cambio irá se basear para gerar as parcelas.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 07/02/06 - 10:00
Revisao     :
Obs.        :
*/
*-------------------------------*
Function Ae109SetCambio(cTipo) 
*-------------------------------*
Local nRecnoIp := WorkIp->(Recno()), nTotPed := M->EEC_TOTPED

Begin Sequence
   If cTipo <> ST_WI .And. cTipo <> ST_WO
      Break
   EndIf
   WorkIp->(DbGoTop())
   While WorkIp->(!Eof())
      If WorkIp->WP_FLAG == cMarca
         WorkIp->(DbSkip())
         Loop
      EndIf
      If Empty(WorkIp->EE9_DTFIX)
         Break
      EndIf
      If cTipo == ST_WI
         WorkIp->EE9_PRECO -= WorkIp->WK_PRCAUX
      ElseIf cTipo == ST_WO
         WorkIp->EE9_PRECO := WorkIp->(WK_PRCAUX - EE9_PRECO)
      EndIf
      WorkIp->(DbSkip())
   EndDo
   Ae100PrecoI()
   nTotPed := M->EEC_TOTPED
   WorkIp->(DbGoTop())
   While WorkIp->(!Eof())                   
      If cTipo == ST_WI
         WorkIp->EE9_PRECO += WorkIp->WK_PRCAUX
      ElseIf cTipo == ST_WO
         WorkIp->EE9_PRECO := WorkIp->(WK_PRCAUX + EE9_PRECO)
      EndIf
      WorkIp->(DbSkip())
   EndDo
   Ae100PrecoI()
   WorkIp->(DbGoTo(nRecnoIp))
   
End Sequence

Return nTotPed

/*
Funcao      : Ae109DetMan
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Selecionar os itens a vincular com o Wash-Out de contrato.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 10:00
Revisao     :
Obs.        :
*/
*------------------------------*
Function Ae109DetMan() 
*------------------------------*
Local lInverte := .f.
Local bOk     := {|| nOpcA := 1, oDlg:End()}
Local bCancel := {|| oDlg:End()}
Local cFileBak1
Local nOpcA := 0
Local aButtons := {}
Local oDlg
Local bCont := {|| If(!Empty(WorkIP->WP_FLAG),SumTotal(),) }
Private oMark

Private aCampoPIT:={{"WP_FLAG","","  "},;
                   {{||WorkIp->EE9_SEQUEN},"",AvSx3("EE9_SEQUEN",AV_TITULO)},; //"Sequência"
                   {{||WorkIp->EE9_COD_I},"",AvSx3("EE9_COD_I",AV_TITULO)},; //"Cód.Item"
                   {{||MEMOLINE(WorkIp->EE9_VM_DES,60,1)},"",AvSx3("EE9_VM_DES",AV_TITULO)},; //"Descrição"
                   {{||TRANSF(WorkIp->EE9_PRECO,EECPreco("EE9_PRECO", AV_PICTURE))},"",AvSx3("EE9_PRECO",AV_TITULO)},; //"Preço Unit."
                   {{||TRANSF(WorkIp->EE9_SLDINI,AVSX3("EE9_SLDINI",AV_PICTURE))},"",AvSx3("EE9_SLDINI",AV_TITULO)}} //"Quantidade"

Begin Sequence
   If Empty(M->EEC_PREEMB)
      Break
   EndIf

   aFilter := EECSaveFilter("WorkIp")
   WorkIp->(DbClearFilter())
   
   cFileBak1 := CriaTrab(,.f.)
   dbSelectArea("WorkIp")
   TETempBackup(cFileBak1)
   WorkIp->(DbGoTop())
   
   DEFINE MSDIALOG oDlg TITLE STR0012+M->EEC_PEDREF FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Seleção de Itens - "
    oDlg:lEscClose := .F.
    @ 18,04 SAY STR0013 PIXEL //"Nro. Processo"
    @ 18,48 MSGET M->EEC_PEDREF SIZE 60,7 WHEN .F. PIXEL
    @ 32,04 SAY STR0014 PIXEL //"Dt.Processo  : "
    @ 32,48 MSGET EE7->EE7_DTPROC SIZE 40,7 WHEN .F. PIXEL

    aPos := PosDlg(oDlg)
    aPos[1] := 48
    WorkIp->(DbGoTop())
    //by CRF - 14/10/2010 - 12:00
    aCampoPIT := AddCpoUser(aCampoPIT,"EE9","5","WorkIp")	
    oMark := MsSelect():New("WorkIp","WP_FLAG",,aCampoPIT,@lInverte,@cMarca,aPos)
    If nSelecao <> VISUALIZAR .And. nSelecao <> EXCLUIR
       oMark:bAval := {|| If(Empty(WorkIp->WP_FLAG),Ae109MarkIt(ALT_DET),Ae109MarkIt(ALT_DET))}
    Else
       oMark:bAval := {|| Ae109MarkIt(VIS_DET) }
    EndIf
    
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))
     
   If nOpcA != 1 // Cancel
      dbSelectArea("WorkIp")
      AvZap()
      TERestBackup(cFileBak1)
      WorkIp->(DbGoTop())
   Else
      M->EEC_PESLIQ := M->EEC_PESBRU := M->EEC_TOTITE := M->EEC_TOTPED:=0
      WorkIp->(dbEval(bCont))
      Ae100PrecoI(.T.)
      EECTotCom(OC_EM,,.t.)
      AE100TTELA(.F.)
   EndIf

End Sequence

 
EECRestFilter(aFilter)
WorkIp->(DbGoTop())

E_EraseArq(cFileBak1)

Return Nil

/*
Funcao      : Ae109MarkIt
Parametros  : lMarca -> Indica se o item será vinculado ou desvinculado
Retorno     : Nenhum.
Objetivos   : Vincular/Desvincular um item ao Wash-Out de contrato
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*--------------------------------*
Function Ae109MarkIt(nOpc)
*--------------------------------*
Local aAltera := {{"EE9_SLDINI",{|| Ae109Valid("EE9_SLDINI")},&("{|| lWhen }"),.T.},;//Campos que podem ser alterados {"NOME",bValid,bWhen,lObrigatorio}
                  {"EE9_DIFERE",{|| Ae109Valid("EE9_DIFERE")},&("{|| lWhen .And. Empty(M->EE9_DTFIX) }"),.T.},;
                  {"EE9_MESFIX",,&("{|| lWhen .And. Empty(M->EE9_DTFIX) }"),.T.},;
                  {"EE9_PRECO", {|| AE109Valid("EE9_PRECO") },&("{|| lWhen .And. !Empty(M->EE9_DTFIX) }"),.T.},;
                  {"EE9_CODAGE",,,.F.},;
                  {"EE9_PERCOM",,{|| Ae100W("EE9_PERCOM") .And. lWhen},.F.}}
Local aButtons := {}, aCpos := {}
Local lOk := .F.
Local bOk     := {|| If(nOpc == VIS_DET .Or. AE109Valid("ITEM"),(lOk := .T., oDlg:End()),)}
Local bCancel := {|| oDlg:End()}
Local bValid := Nil, bWhen := Nil, lObrigat := .F.
Local nRecnoIp, i, nInc
Local lPrcFix, lItMark := .F., lWashOutAD := .F.
Local cAlias := "EE9"

Private aCposDet := {}

Begin Sequence
   
   If Empty(WorkIp->WP_FLAG) .Or. nOpc == VIS_DET
      If nOpc <> VIS_DET
         nRecnoIp := WorkIp->(Recno())
         WorkIp->(DbGoTop())
         While WorkIp->(!Eof())
            If !Empty(WorkIp->WP_FLAG)
               If Empty(EE8->EE8_DTFIX)
                  lPrcFix := .F.
               Else
                  lPrcFix := .T.
               EndIf
               Exit
            EndIf
            WorkIp->(DbSkip())
         EndDo
         WorkIp->(DbGoTo(nRecnoIp))

         If M->EEC_STATUS == ST_WA
            //Define o tipo de Wash-Out para itens com preço fixado
            If !Empty(WorkIp->EE9_DTFIX)
               lWashOutAD := .T.
               If !Ae109TipoWO()
                  Break
               EndIf
            EndIf
         Else
            If ValType(lPrcFix) == "L"
               If Empty(WorkIp->EE9_DTFIX) .And. lPrcFix
                  MsgInfo(STR0058, STR0050)//"Existe um item marcado com preço fixado. Somente será possível marcar itens com preço fixado." ### "Atenção"
                  Break
               ElseIf !Empty(WorkIp->EE9_DTFIX) .And. !lPrcFix
                  MsgInfo(STR0059, STR0050)//"Existe um item marcado sem preço fixado. Somente será possível marcar itens sem preço fixado." ### "Atenção"
                  Break
               EndIf
            EndIf
         EndIf
      EndIf

      For nInc := 1 To WorkIP->(FCount())
         M->&(WorkIP->(FieldName(nInc))) := WorkIP->(FieldGet(nInc))
      Next nInc
      SX3->(DbSetOrder(1))
      SX3->(DbSeek(cAlias))
      While SX3->(!Eof() .And. X3_ARQUIVO == cAlias)
         If SX3->X3_CONTEXT == "V"
            M->&((cAlias)->(SX3->X3_CAMPO)) := CRIAVAR(SX3->X3_CAMPO)
         EndIf
         SX3->(DbSkip())
      EndDo

      //*** Define os campos que serão mostrados ao alterar um item
      aCpos := aItemEnchoice
      For i := 1 To Len(aCpos)
         If (x := aScan(aAltera,{|x| x[1] = aCpos[i]})) > 0 .And. nOpc <> VIS_DET
            If(!Empty(aAltera[x][3]), bWhen := aAltera[x][3],bWhen := {|| .T.})
            bValid   := aAltera[x][2]
            If(!Empty(aAltera[x][4]), lObrigat := aAltera[x][4],lObrigat :=.F. )
         Else
            bWhen    := {|| .F.}
            bValid   := Nil
            lObrigat := .F.
         EndIf
         aAdd(aCposDet, {aCpos[i],bValid,bWhen,lObrigat,})
      Next
      //***
      
      DEFINE MSDIALOG oDlg TITLE STR0007 + " - " + M->EEC_PREEMB FROM DLG_LIN_INI,DLG_COL_INI; //"Wash-Out Contrato - " 
                                                                TO DLG_LIN_FIM,DLG_COL_FIM; 
                                                                OF oMainWnd PIXEL
      oDlg:lEscClose := .F.
      aPos := PosDlg(oDlg)
      aPos[3] -= 15
     
      AE109Gets(oDlg, aPos, aCposDet)
      For i := 1 To Len(aMemoItem)
         If WorkIp->(FieldPos(aMemoItem[i,2])) > 0
            M->&(aMemoItem[i,2]) := WorkIp->&(aMemoItem[i,2])
         EndIf
      Next
      
      lAltera := .T.
      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons))
      lAltera := .F.
      
      If nOpc == VIS_DET
         Break
      EndIf
          
      If lOk
         Ae100Calc("PESOS")
         AvReplace("M","WorkIp")
         WorkIp->WP_FLAG := cMarca
         If M->EEC_STATUS == ST_WA
            If (nDif := WorkIp->(WK_DIFERE - EE9_DIFERE)) > 0
               M->EXL_TIPOWO := ST_WI
            ElseIf nDif == 0
               M->EXL_TIPOWO := ST_WN
            Else
               M->EXL_TIPOWO := ST_WO
            EndIf
            M->EEC_STTDES := Tabela("YC", M->(EEC_STATUS := EXL_TIPOWO))
         EndIf
  
         If Empty(WorkIP->EE9_SEQEMB)
            nRecNo  := WorkIP->(RecNo())
            WorkIp->(DbSetOrder(1))
            WorkIp->(DbGoBottom())
            cSeqEmb := Str(Val(WorkIP->EE9_SEQEMB)+1,AvSx3("EE9_SEQEMB",AV_TAMANHO))
            WorkIp->(DbSetOrder(2))
            WorkIp->(DbGoTo(nRecNo))
            WorkIp->EE9_SEQEMB := cSeqEmb
            M->EE9_SEQEMB := cSeqEmb
         Endif
      Else
         M->EXL_TIPOWO := ST_WA
         M->EEC_STTDES := Tabela("YC", M->(EEC_STATUS := EXL_TIPOWO))
      EndIf               
   
   Else
      If(WorkIp->WP_OLDINI == 0, WorkIp->WP_OLDINI := WorkIp->EE9_SLDINI,)
      EE8->(DbSetOrder(1))
      EE8->(DbSeek(xFilial("EE8")+M->EEC_PEDREF+WorkIp->EE9_SEQUEN))
      WorkIp->EE9_SLDINI := EE8->EE8_SLDATU + WorkIp->WP_OLDINI
      WorkIp->WP_FLAG   := Space(2)
      WorkIp->EE9_DIFERE := EE8->EE8_DIFERE
      nRecnoIp := WorkIp->(Recno())
      WorkIp->(DbGoTop())
      WorkIp->(DbEval({|| If(!Empty(WorkIp->WP_FLAG),lItMark := .T.,) }))
      WorkIp->(DbGoTo(nRecnoIp))
      If !lItMark
         M->EXL_TIPOWO := ST_WA
         M->EEC_STTDES := Tabela("YC", M->(EEC_STATUS := EXL_TIPOWO))
      EndIf
   EndIf

oMark:oBrowse:Refresh()
End Sequence

Return Nil

/*
Funcao      : Ae109RestSaldo(lSoma)
Parametros  : lSoma -> .T. - Restaura o Saldo
                       .F. - Abate o Saldo
Retorno     : Nenhum.
Objetivos   : Restaura/Abate o saldo do item no pedido conforme contrato de Wash-Out.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*-----------------------------------*
Static Function Ae109RestSaldo(lSoma)
*-----------------------------------*
Local i,j
nRecno := WorkIp->(Recno())
WorkIp->(DbGoTop())
While WorkIp->(!Eof())
   If WorkIp->WP_OLDINI > 0
      For j := 1 To 2
         If(j == 1,cFil := cFilBr,cFil := cFilEx)
         If !IsProcOffShore(M->EEC_PEDREF,OC_PE,cFilEx) .and. cFil == cFilBr
            Loop
         EndIf
         EE8->(DbSetOrder(1))
         EE8->(DbSeek(cFil+M->EEC_PEDREF+WorkIp->EE9_SEQUEN))
         EE8->(RecLock("EE8",.F.))
         EE8->EE8_SLDATU += WorkIp->WP_OLDINI
         EE8->(MsUnlock())
         If(cFil == cFilBr, Ae109SldRV(.F.),)
      Next
   EndIf
   WorkIp->(DbSkip())
EndDo

WorkIp->(DbGoTop())
While WorkIp->(!Eof())
   If !Empty(WorkIp->WP_FLAG) .And. If(nSelecao <> EXCLUIR,(Empty(WorkIp->WP_RECNO) .Or. (WorkIp->WP_OLDINI > 0)),.T.)
      For i := 1 To 2
         If(i == 1,cFil := cFilBr,cFil := cFilEx)
         If !IsProcOffShore(M->EEC_PEDREF,OC_PE,cFilEx) .and. cFil == cFilBr
            Loop
         EndIf
         EE8->(DbSetOrder(1))
         EE8->(DbSeek(cFil+M->EEC_PEDREF+WorkIp->EE9_SEQUEN))
         EE8->(RecLock("EE8",.F.))
         If(lSoma, EE8->EE8_SLDATU += WorkIp->EE9_SLDINI, EE8->EE8_SLDATU -= WorkIp->EE9_SLDINI)
         EE8->(MsUnlock())
         If(cFil == cFilBr, Ae109SldRV(lSoma == .F.),)
      Next
   EndIf
   WorkIp->(DbSkip())
EndDo
WorkIp->(DbGoTo(nRecno))

Return Nil

/*
Funcao      : Ae109SldRV(lSoma)
Parametros  : lSoma -> .T. - Restaura o saldo
                       .F. - Abate o saldo
Retorno     : Nenhum
Objetivos   : Restaura/Abate o saldo do item no R.V. vinculado ao mesmo
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*--------------------------------*
Static Function Ae109SldRV(lSoma)
*--------------------------------*
Local aOrd := SaveOrd({"EE8","EEY"})

Begin Sequence
   
   If !Empty(EE8->EE8_RV)
      cEE8_RV    := EE8->EE8_RV
      nEE8_PRECO := EE8->EE8_PRECO
      dEE8_DTFIX := EE8->EE8_DTFIX
      EEY->(DbSetOrder(1))
      EEY->(DbSeek(cFilBr+EE8->EE8_RV))
      While EEY->(!Eof() .And. EEY->EEY_NUMRV == EE8->EE8_RV)
         EE8->(DbSetOrder(1))
         EE8->(DbSeek(cFilBr+EEY->EEY_PEDIDO))
         If EE8->EE8_RV    == cEE8_RV    .And.;
            EE8->EE8_PRECO == nEE8_PRECO .And.;
            EE8->EE8_DTFIX == dEE8_DTFIX
            EE8->(RecLock("EE8",.F.))
            If(lSoma, EE8->EE8_SLDATU += WorkIp->WP_OLDINI, EE8->EE8_SLDATU -= WorkIp->WP_OLDINI)
            EE8->(MsUnlock())
            Break            
         EndIf
         EEY->(DbSkip())
      EndDo
   EndIf
   
End Sequence

RestOrd(aOrd, .T.)
Return Nil

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 
Revisao     :
Obs.        :
*/
*----------------------*
Function AE109CtGrvWk()
*----------------------*
Local nRecno, nVlComis := 0
                
Begin Sequence
   
   If Inclui
      cChave   := M->EEC_PEDREF   //Copia para o processo os complementos do pedido
      cOcorren := OC_PE
   Else   
      cChave   := EEC->EEC_PREEMB //Busca os complementos do embarque
      cOcorren := OC_EM
   EndIf
   //*** Alimenta Work de Despesas
   bAddWork := {|| WorkDe->(dbAppEnd()),AP100DSGrava(.T.,OC_EM), If(Inclui, (WorkDe->EET_RECNO := 0),)}
   EET->(dbSetOrder(1))
   cKey := AVKey(cChave,"EET_PEDIDO")
   EET->(dbSeek(xFilial("EET")+AvKey(cKey,"EET_PEDIDO")+cOcorren))
   EET->(dbEval(bAddWork,,{||EET->EET_FILIAL == xFilial("EET") .And. ;
   EET->EET_PEDIDO+EET->EET_OCORRE == AvKey(cKey,"EET_PEDIDO")+cOcorren}))
   //***
      
   //*** Alimenta Work de Agentes               
   bAddWork  := {|| WorkAg->(dbAppEnd()),AP100AGGrava(.T.,OC_EM), If(Inclui, (WorkAg->WK_RECNO := 0),)}
   EEB->(dbSetOrder(1))
   EEB->(dbSeek(xFilial("EEB")+cChave+cOcorren))
   EEB->(dbEval(bAddWork,,{||  !EEB->(EOF()) .AND. EEB->EEB_FILIAL == xFilial("EEB") .And. EEB->EEB_PEDIDO == cChave .AND. EEB->EEB_OCORRE==cOcorren}))
   //***

   //*** Alimenta Work de Instituicoes Financeiras
   bAddWork := {|| WorkIn->(dbAppEnd()),AP100INSGrava(.T.,OC_EM), If(Inclui, (WorkIn->WK_RECNO := 0),)}
   EEJ->(dbSetOrder(1))
   EEJ->(dbSeek(xFilial("EEJ")+cChave+cOcorren))
   EEJ->(dbEval(bAddWork,,{||  !EEJ->(EOF()) .AND. EEJ->EEJ_FILIAL == xFilial("EEJ") .And. EEJ->EEJ_PEDIDO == cChave .AND. EEJ->EEJ_OCORRE==cOcorren}))
   //***
   
   //Alimenta Trata Work de Notify's
   bAddWork := {|| WorkNo->(dbAppend()),AP100NoGrv(.T.,OC_EM), If(Inclui, (WorkNo->WK_RECNO := 0),)}  
   EEN->(DBSETORDER(1))
   EEN->(dbSeek(xFilial("EEN")+cChave+cOcorren))
   EEN->(dbEval(bAddWork,,{||  !EEN->(EOF()) .AND. EEN->EEN_FILIAL == xFilial("EEN") .And. EEN->EEN_PROCES == cChave .AND. EEN->EEN_OCORRE==cOcorren}))
   //***

   If !Inclui
      Ae109GrvItWk()
   EndIf   
   
End Sequence

//Inclui na Work todos os itens do Pedido que ainda não estão na Work
Processa({|| Ae109SelIt()},STR0037,STR0038)//"Gravando Informações." ### "Prep. do embarque"

Return Nil

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 
Revisao     :
Obs.        :
*/
*--------------------*
Function Ae109GrvItWk()
*--------------------*
Local nRecno, nVlComis := 0, nPrecoAux := 0, i

Begin Sequence
   //**Busca itens já vinculados
   EE8->(dbSetOrder(1))
   EE7->(dbSetOrder(1))
   EE9->(dbSetOrder(2))
   EE9->(dbSeek(xFilial("EE9")+M->EEC_PREEMB))

   M->EEC_TOTPED := 0

   While !EE9->(Eof()) .AND. EE9->EE9_FILIAL == xFilial("EE9") .And. EE9->EE9_PREEMB == M->EEC_PREEMB
      
      If cStatus == ST_WR
         If !EE8->(dbSeek(XFILIAL("EE8")+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
            EE9->(RecLock("EE9",.F.))
            EE9->(DbDelete())
            EE9->(MsUnlock())
            EE9->(DbSkip())
            Loop
         EndIf
      EndIf
      WorkIp->(DbAppend())

      AvReplace("EE9","WorkIp")

      For i := 1 To Len(aMemoItem)
         If WorkIp->(FieldPos(aMemoItem[i,2])) > 0
            WorkIp->&(aMemoItem[I,2]) := MSMM(EE9->&(aMemoItem[I,1]),AVSX3(aMemoItem[I,2],AV_TAMANHO))
         EndIf
      Next

      WorkIp->WP_FLAG := cMarca
      WorkIp->WP_RECNO  :=EE9->(RECNO())
      WorkIp->TRB_ALI_WT:= "EE9"
      WorkIp->TRB_REC_WT:= EE9->(Recno())
      
      
      IF EE8->(dbSeek(XFILIAL("EE8")+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
         WorkIp->WP_SLDATU := EE8->EE8_SLDATU
         WorkIp->WK_PRCAUX := EE8->EE8_PRECO
         WorkIp->EE9_DTFIX := EE8->EE8_DTFIX
         WorkIp->WK_DIFERE := EE8->EE8_DIFERE
         
      EndIf
       
      M->EE9_SEQEMB := WorkIp->EE9_SEQEMB
      M->EE9_SLDINI := WorkIp->EE9_SLDINI
      M->EE9_COD_I  := WorkIp->EE9_COD_I
      M->EE9_EMBAL1 := WorkIp->EE9_EMBAL1
      M->EE9_QTDEM1 := WorkIp->EE9_QTDEM1
      M->EE9_PEDIDO := WorkIp->EE9_PEDIDO
      M->EE9_SEQUEN := WorkIp->EE9_SEQUEN
      M->EEC_TOTPED += M->EEC_SEGPRE
      M->EEC_TOTPED += M->EEC_FRPREV
      M->EEC_TOTPED += AvGetCpo("M->EEC_DESP1")
      M->EEC_TOTPED += AvGetCpo("M->EEC_DESP2")
      M->EEC_TOTPED += M->EEC_DESPIN
      M->EEC_TOTPED += M->EEC_FRPCOM
      M->EEC_TOTPED -= M->EEC_DESCON
      M->EEC_TOTPED -= nVlComis

      EE9->(DbSkip())
   EndDo
   //*** 
   If cStatus == ST_WR
      WorkIp->(DbGoTop())
      M->EE9_PRECO := WorkIp->EE9_PRECO
   EndIf
End Sequence

Return Nil   

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 
Revisao     :
Obs.        :
*/
*--------------------*
Function Ae109SelIt()
*--------------------*
Local bGETSETEE8,bGETSETEE9
Local aOrd := SaveOrd({"EE8"})
Local cCampoCod, cCampoMem
Local i, j
Begin Sequence
   
   WorkIp->(dbSetOrder(2))
   EE8->(dbSetOrder(1))
   
   ProcRegua(EE8->(LASTREC()))
   EE8->(dbSeek(XFILIAL("EE8")+M->EEC_PEDREF))
   Do While !EE8->(EOF()) .AND. XFILIAL("EE8")==EE8->EE8_FILIAL .AND.;
            M->EEC_PEDREF == EE8->EE8_PEDIDO
      If !(EE8->EE8_SLDATU > 0)// .Or. Empty(EE8->EE8_DTFIX) Aceita itens sem preço fixado.
         EE8->(DbSkip())
         Loop
      EndIf
      
      IncProc()
      If !WorkIp->(dbSeek(M->EEC_PEDREF+EE8->EE8_SEQUEN))
         WorkIp->(DbAppend())
         For i:=1 To EE8->(FCount())
            cField := EE8->(FieldName(i))
            bGETSETEE8:=FIELDWBLOCK(cFIELD,SELECT("EE8"))
            cFIELDEE9:="EE9"+SUBSTR(ALLTRIM(cFIELD),4)
            bGETSETEE9:=FIELDWBLOCK(cFIELDEE9,SELECT("WorkIp"))
            If ( WorkIp->(FIELDPOS(cFIELDEE9))#0)
               EVAL(bGETSETEE9,EVAL(bGETSETEE8))
            Endif
         Next i
               
         For j := 1 To Len(aMemoItem)
            cCampoCod := "EE8"+Substr(aMemoItem[j,1],4,7)
            cCampoMem := "EE8"+Substr(aMemoItem[j,2],4,7)
            If EE8->(Fieldpos(cCampoCod)) > 0 .And. AvSX3(cCampoMem,,,.t.) .And.;
               EE9->(Fieldpos(aMemoItem[j,1])) > 0 .And. AvSX3(aMemoItem[j,2],,,.t.)
               WorkIp->&(aMemoItem[j,2]) := MSMM(&("EE8->"+cCampoCod),AVSX3(cCampoMem)[AV_TAMANHO])
            EndIf
         Next 
         WorkIp->WK_PRCAUX := EE8->EE8_PRECO
         
         //saldos de quantidade na 1. vez (embarque total)
         WorkIp->EE9_PREEMB := M->EEC_PREEMB
         WorkIp->EE9_SLDINI := EE8->EE8_SLDATU
         WorkIp->WP_SLDATU  := EE8->EE8_SLDATU
         WorkIp->WP_FLAG    := ""
         WorkIp->WK_DIFERE  := EE8->EE8_DIFERE
         WorkIp->EE9_PRCTOT := 0
         WorkIp->EE9_PRCINC := 0
         WorkIp->EE9_PSLQTO := 0
         WorkIp->EE9_PSBRTO := 0
               
      EndIf
      EE8->(DbSkip(1))
   Enddo
      
   
End Sequence
   
RestOrd(aOrd)
   
Return Nil

/*
Funcao      : Ae109GetEmbBr
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Obter o número do embarque a ser gerado na filial Brasil.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*-----------------------------*
Function Ae109GetEmbBr()
*-----------------------------*
Local aOrd := SaveOrd("EEC")
Local bOk     := {|| If(Eval(bValid),(lRet := .T., oDlg:End()),)} 
Local bCancel := {|| oDlg:End() }  
Local bValid  := {|| If(ExistChav("EEC", M->EXL_WOEMB), .T., .F.) }
Local oDlg
Local lRet := .F.

cFilOld  := AvGetM0Fil()
cFilAnt  := cFilbr
EECFilterEmb("EMBARQUE")
//DEFINE MSDIALOG oDlg TITLE STR0007 FROM 331,360 TO 415,600 OF oMainWnd PIXEL //"Wash-Out Contrato"
 //nBorda1 := (oDlg:nClientHeight - 2.5)/2   
 //nBorda2 := (oDlg:nClientWidth - 2.5)/2

//** PLB 09/04/07 - Alteração das dimensoes devido às diferencas de exibicao entre Temas 'Ocean' e 'Flat'
DEFINE MSDIALOG oDlg TITLE STR0007 FROM 331,360 TO 440,720 OF oMainWnd PIXEL //"Wash-Out Contrato"
 nBorda1 := (oDlg:nClientHeight - 32)/2   
 nBorda2 := (oDlg:nClientWidth - 18)/2
//**

 oDlg:lEscClose := .F.

 @ 14,2 To nBorda1, nBorda2 Label STR0039 Pixel //"Informe o nro. do processo na filial Brasil:"
 @ 25,6 MsGet M->EXL_WOEMB PICTURE "@!" Size 110,07 Pixel Of oDlg

Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered
cFilAnt  := cFilOld
EECFilterEmb("WASHOUT")   
RestOrd(aOrd, .T.)
Return lRet

/*
Funcao      : Ae109Defs
Parametros  : cTipo -> Indica se foi chamada pela rotina de Wash-Out de Contrato ou R.V.
Retorno     : Nenhum.
Objetivos   : Defições para as Works e campos a ser exibidos
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*-----------------------------*
Static Function Ae109Defs(cTipo)
*-----------------------------*
Local aWork   := {},;
      aSemSx3 := {},;
      aIndex  := {}
Begin Sequence
   If cTipo == "WORKS"
      //*** Definições para a Work de Itens (EE9)
      aSemSx3 := { {"WP_RECNO" ,"N",7,0},;
                   {"WP_FLAG"  ,"C",2,0},;
                   {"WP_SLDATU","N",15,3},;
                   {"WP_SLDORI","N",15,3},;
                   {"WP_OLDINI",AVSX3("EE9_SLDINI",2),AVSX3("EE9_SLDINI",3),AVSX3("EE9_SLDINI",4)},;
                   {"WK_TOTOIC" ,"N", 15, 3},;
                   {"WK_QTDOIC" ,"N", 15, 3},;
                   {"EE9_DTFIX", "D",  8, 0}}
                  
      If EE9->(FieldPos("EE9_PRCUN"))  > 0 .And. EE9->(FieldPos("EE9_VLFRET")) > 0 .And. ;
         EE9->(FieldPos("EE9_VLSEGU")) > 0 .And. EE9->(FieldPos("EE9_VLOUTR")) > 0 .And. ;
         EE9->(FieldPos("EE9_VLDESC")) > 0
         
         aAdd(aSemSX3,{"EE9_PRCUN" ,AVSX3("EE9_PRCUN" ,AV_TIPO),AVSX3("EE9_PRCUN" ,AV_TAMANHO),AVSX3("EE9_PRCUN" ,AV_DECIMAL)})
         aAdd(aSemSX3,{"EE9_VLFRET",AVSX3("EE9_VLFRET",AV_TIPO),AVSX3("EE9_VLFRET",AV_TAMANHO),AVSX3("EE9_VLFRET",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE9_VLSEGU",AVSX3("EE9_VLSEGU",AV_TIPO),AVSX3("EE9_VLSEGU",AV_TAMANHO),AVSX3("EE9_VLSEGU",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE9_VLOUTR",AVSX3("EE9_VLOUTR",AV_TIPO),AVSX3("EE9_VLOUTR",AV_TAMANHO),AVSX3("EE9_VLOUTR",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE9_VLDESC",AVSX3("EE9_VLDESC",AV_TIPO),AVSX3("EE9_VLDESC",AV_TAMANHO),AVSX3("EE9_VLDESC",AV_DECIMAL)})
          
      Else
         aAdd(aSemSX3,{"EE9_PRCUN" ,AVSX3("EE9_PRECO" ,AV_TIPO),AVSX3("EE9_PRECO" ,AV_TAMANHO),AVSX3("EE9_PRECO" ,AV_DECIMAL)})
         aAdd(aSemSX3,{"EE9_VLFRET",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE9_VLSEGU",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE9_VLOUTR",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE9_VLDESC",AVSX3("EE9_PRCTOT",AV_TIPO),AVSX3("EE9_PRCTOT",AV_TAMANHO),AVSX3("EE9_PRCTOT",AV_DECIMAL)})
      
      EndIf
      
      aAdd(aSemSX3,{"WP_PRCRV",AVSX3("EE8_PRECO",AV_TIPO),AVSX3("EE9_PRECO",AV_TAMANHO),AVSX3("EE9_PRECO",AV_DECIMAL)})

      aAdd(aSemSX3,{"WK_PRCAUX",AVSX3("EE9_PRECO",2),AVSX3("EE9_PRECO",3),AVSX3("EE9_PRECO",4)})
      
      aAdd(aSemSX3,{"WK_DIFERE",AVSX3("EE8_DIFERE",2),AVSX3("EE8_DIFERE",3),AVSX3("EE8_DIFERE",4)})
      
      AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
      AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
      
      AddNaoUsado(aSemSX3,"EE9_MESFIX")
      AddNaoUsado(aSemSX3,"EE9_DIFERE")
      
      
      aIndex  := {{,"EE9_PEDIDO+EE9_SEQUEN"},;
                  {"cNomArq2","EE9_SEQEMB"}}
      aWork   := {"WorkIp","EE9","cNomArq1",,,aSemSx3,aIndex,}
      aAdd(aWorks, aWork)
      aAdd(aWkChRecno, {"EE9", "WorkIp", "WP_RECNO", "2", "EE9_PREEMB", "aDeletados", })
      //***
      
      //*** Definições para a Work de Notify's
      aSemSx3 := { {"WK_RECNO","N", 7, 0},{"EEN_OCORRE","C",1,0} }
      aIndex  := {{,"EEN_IMPORT+EEN_IMLOJA"}}
      aWork   := {"WorkNo","EEN","cNomArq3",,ARRAY(EEJ->(FCOUNT())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)                           
      aAdd(aWkChRecno, {"EEN", "WorkNo", "WK_RECNO", "1", "EEN_PROCES", "aNoDeletados", })
 
      aNoEnchoice := {"EEN_IMLOJA","EEN_IMPODE","EEN_IMPORT","EEN_ENDIMP","EEN_END2IM"}
      aNoPos      := {55,4,140,261}               //Posicao da Enchoice
      aNoBrowse   := { {"EEN_IMPORT",, STR0085},; //STR0085	"Notify"
                       {"EEN_IMLOJA",,STR0086},; //STR0086	"Loja"
                       {"EEN_IMPODE",,STR0078} } //STR0078	Descrição
      // ***

      //*** Definições para a Work de Despesas
      aSemSX3  := {{"EET_RECNO", "N", 7, 0}}
      
      aOrd := SaveOrd("SX3",2)
      cCpo := "EET_OCORRE"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif
      RestOrd(aOrd)
  
      aIndex  := {{,"EET_PEDIDO+EET_DESPES+Dtos(EET_DESADI)"}}
      aWork   := {"WorkDe","EET","cNomArq4",,Array(EET->(FCount())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)
      aAdd(aWkChRecno, {"EET", "WorkDe", "EET_RECNO", "1", "EET_PEDIDO", "aDeDeletados", "EET_DESPES"})

      aDeEnchoice := {"EET_PEDIDO","EET_DESPES","EET_DESCDE","EET_DESADI",;
                      "EET_VALORR","EET_BASEAD","EET_DOCTO",;
                      "EET_PAGOPO","EET_RECEBE","EET_REFREC"}
   
      aDePos    := {55,4,140,261} //posicao da enchoice
      aDeBrowse := { {{|| WorkDE->EET_DESPES+" "+if(SYB->(dbSeek(xFilial("SYB")+WorkDE->EET_DESPES)),SYB->YB_DESCR,"")},,"Cancelar"},; //"Despesa"
                       ColBrw("EET_DESADI","WorkDE"),;
                       ColBrw("EET_VALORR","WorkDE"),;
                       {{|| IF(WorkDE->EET_BASEAD $ cSim,"Sim","Não") },,"Adiantamento ?"},;
                       ColBrw("EET_DOCTO","WorkDE") } 
      //***
                   
      //*** Definições para a Work de Agentes
      aAgEnchoice := {"EEB_CODAGE","EEB_NOME","EEB_TIPOAG"} //"EEB_TXCOMI","EEB_TXSERV","EEB_TXEMBA","EEB_TXFRET"}
      aAgPos    := {55,4,140,261}               //posicao da enchoice
      aAgBrowse := { {"EEB_CODAGE",,STR0087},; //STR0087	"Codigo"
                     {"EEB_NOME",,STR0088},; //STR0088	"Razão Social"
                     {"EEB_TIPOAG",,STR0089}} //STR0089	"Classificação"
       
      If EE9->(FieldPos("EE9_TIPCOM")) > 0
         aAdd(aAgBrowse,{{||BscxBox("EEB_TIPCOM",WorkAg->EEB_TIPCOM) },,AvSx3("EEB_TIPCOM",AV_TITULO)})
      EndIf
      
      AddNaoUsado(aSemSX3,"EEB_FOBAGE")
      AddNaoUsado(aSemSX3,"EEB_TOTCOM")      

      aIndex := {}

      If EECFlags("COMISSAO")
         aAdd(aIndex,{,"EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM"})
      Else                                                 
         aAdd(aIndex,{,"EEB_CODAGE+EEB_TIPOAG"})
      EndIf

      aSemSX3  := {{"WK_RECNO", "N", 7, 0},{"EEB_OCORRE","C",1,0}}
      AddNaoUsado(aSemSX3,"EEB_FOBAGE")
      AddNaoUsado(aSemSX3,"EEB_TOTCOM")
      aWork   := {"WorkAg","EEB","cNomArq5",,Array(EEB->(FCount())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)
      aAdd(aWkChRecno, {"EEB", "WorkAg", "WK_RECNO", "1", "EEB_PEDIDO", "aAgDeletados", })
      //***

      //*** Definições para a Work de Instituições      
      aInEnchoice := {"EEJ_CODIGO","EEJ_AGENCI","EEJ_NUMCON","EEJ_NOME","EEJ_TIPOBC"} 
      aInPos      := {55,4,140,261}                   //Posicao da enchoice
      aInBrowse   := { {"EEJ_CODIGO",,STR0087},;     //STR0087	"Codigo"	
                       {"EEJ_AGENCI",,STR0090},;    //	STR0090	"Agência"
                       {"EEJ_NUMCON",,STR0091},;   //	STR0091	"Conta"
                       {"EEJ_NOME"  ,,STR0092},;  //	STR0092	"Nome"
                       {"EEJ_TIPOBC",,STR0093} } //STR0093	"Relação"

      aSemSX3 := { {"WK_RECNO", "N", 7, 0},{"EEJ_OCORRE","C",1,0} }
      aIndex := {{,"EEJ_TIPOBC+EEJ_CODIGO+EEJ_NUMCON"}}
      aWork   := {"WorkIn","EEJ","cNomArq6",,Array(EEJ->(FCount())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)
      aAdd(aWkChRecno, {"EEJ", "WorkIn", "WK_RECNO", "1", "EEJ_PEDIDO", "aInDeletados", "EEJ_CODIGO+EEJ_OCORRE+EEJ_TIPOBC"})
      //***

      //*** Definições para a Work de Notas Fiscais
      aSemSX3 := {{"WK_RECNO","N",7,0}}
      aIndex := {{,"EEM_TIPOCA+EEM_NRNF"}}
      aWork   := {"WorkNF","EEM","cNomArq7",,Array(EEM->(FCount())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)      
      //***

      //*** Definições para a Work de OIC´s
      aSemSX3 := {{"WK_RECNO"  ,"N", 10, 0},;
                  {"WK_FLAG"   ,"C",  2, 0}}
           
      aOrd := SaveOrd("SX3",2)
      cCpo := "EY2_NRINVO"
      IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
         aAdd(aSemSX3,{"WK_NRINVO",AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
      Endif
      RestOrd(aOrd)       

      aIndex  := {{,"EXZ_OIC"}}
      aWork   := {"WKEXZ","EXZ","cNomArq8",,Array(EXZ->(FCount())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)

      aSemSX3 := {{"WK_RECNO","N",7,0}}
      aIndex  := {{,"EY2_OIC+EY2_SEQEMB"},;
                  {"cNomArq9","EY2_SEQEMB"}}
      aWork   := {"WKEY2","EY2","cNomArq10",,Array(EY2->(FCount())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)
      //***

      //*** Definições para a work de Documentos
      aSemSX3 := {{"EEK_CODIGO", "C", 20,0},{"EEK_PEDIDO","C",20,0},{"EEK_SEQUEN","C",6,0}}
     
      aIndex  := {{,"EEK_PEDIDO+EEK_SEQUEN+EEK_CODIGO+EEK_SEQ+EEK_EMB"}}
      aWork   := {"WorkEm","EEK","cNomArq11",,Array(EEK->(FCOUNT())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)
      //***
   
      //*** Definições para a work de Invoices
      aSemSX3 := {{"EXP_RECNO","N", 7, 0}}
      
      aIndex  := {{,"EXP_NRINVO"}}
      aWork   := {"WorkInv","EXP","cNomArq12",,Array(EXP->(FCount())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)
   

      aSemSX3 := {{"EXR_RECNO" ,"N", 7, 0}}

      aIndex  := {{,"EXR_NRINVO+EXR_SEQEMB"},;
                  {"cNomArq14","EXR_SEQEMB"}}
      aWork   := {"WorkDetInv","EXR","cNomArq13",,Array(EXR->(FCount())),aSemSx3,aIndex,}
      aAdd(aWorks, aWork)
      //***
      
      //*** Definições para a Work Auxiliar na Rotina de Wash-Out de R.V.
      If cStatus == ST_WR
         aIndex  := {{,"EE9_PEDIDO+EE9_SEQUEN"},;
                     {"cNomArq16","EE9_SEQEMB"}}
         //TRP - 27/01/07 - Campos do WalkThru
         AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
         AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
         aWork   := {"WorkRV","EE9","cNomArq15",,,aSemSx3,aIndex,}
         aAdd(aWorks, aWork)
      EndIf
      //***

      //*** Definições para a Work de Histórico de Pre-Calculo
      If EECFlags("HIST_PRECALC")  // By JPP 11/12/2006 - 16:00 
         aIndex  := {{,"EXM_DESP"}}
         aSemSX3    := {{"WK_VALR ","N", AvSx3("EXM_VALOR",AV_TAMANHO), AvSx3("EXM_VALOR",AV_DECIMAL)},;
                        {"WK_RECNO","N", 7, 0}}
         aWork   := {"WorkCalc","EXM","cNomArq17",,,aSemSx3,aIndex,}
         aAdd(aWorks, aWork)
      EndIf
      //***
         
   ElseIf cTipo == "CAMPOS"

      //Define os campos que serão mostrados na capa do Embarque -> {"Nome do Campo",bValid,bWhen,lObrigatorio, cTitulo}

      If cStatus <> ST_WR
         aCpos:={{"EEC_PREEMB",{|| Ae109Valid("EEC_PREEMB")},{||nSelecao == 3},.T.,},; //Campos da Capa
                 {"EEC_DTPROC",,,,},;
                 {"EEC_PEDREF",{|| Ae109Valid("EEC_PEDREF")},{||nSelecao == INCLUIR},,,.F.},;
                 {"EEC_STTDES",,{||.F.},,},;
                 {"EEC_IMPORT",,{||.F.},.T.,},;
                 {"EEC_IMLOJA",,{||.F.},.T.,},;
                 {"EEC_IMPODE",,{||.F.},.T.,},;
                 {"EEC_ENDIMP",,{||.F.},.T.,},;
                 {"EEC_END2IM",,{||.F.},.T.,},;
                 {"EEC_CLIENT",,{||.F.},,},;
                 {"EEC_CLLOJA",,{||.F.},,},;
                 {"EEC_CLIEDE",,{||.F.},,},;
                 {"EEC_FORN"  ,,{||.F.},,},;
                 {"EEC_FOLOJA",,{||.F.},,},;
                 {"EEC_FORNDE",,{||.F.},,},;
                 {"EEC_CONDPA",{|| AE109Valid("EEC_CONDPA")},{||lWhen},.T.,},;
                 {"EEC_DIASPA",,,.T.,},;
                 {"EEC_DESCPA",,{||.F.},.T.,},;
                 {"EEC_DSCCOM",,{||.F.},,},;
                 {"EEC_DTEFE" ,,{||.T.},,},;
                 {"EEC_OBS"   ,,{||lWhen},,}}

         aObrigatorios := {"EEC_PREEMB",;
                           "EEC_CONDPA"}
                      
         //definicao de campos para a enchoice dos itens do processo
         aItemEnchoice:={"EE9_COD_I","EE9_PART_N","EE9_FORN","EE9_FABR","EE9_FALOJA","EE9_FOLOJA",;
                         "EE9_VM_DES","EE9_CODQUA","EE9_DSCQUA","EE9_CODPEN","EE9_DSCPEN","EE9_CODTIP",;
                         "EE9_DSCTIP","EE9_CODBEB","EE9_DSCBEB","EE9_PRECO","EE9_DIFERE","EE9_MESFIX","EE9_SLDINI","EE9_QE",;
                         "EE9_EMBAL1","EE9_PSLQUN","EE9_PSBRUN","EE9_QTDEM1","EE9_UNIDAD","EE9_CODAGE",;
                         "EE9_DSCAGE","EE9_MAXCOM","EE9_VLCOM","EE9_POSIPI","EE9_NLNCCA","EE9_NALSH",;
                         "EE9_FPCOD","EE9_GPCOD","EE9_DPCOD","EE9_ATOCON","EE9_RE","EE9_DTRE","EE9_FINALI",;
                         "EE9_PRECOI","EE9_NRSD","EE9_DTAVRB","EE9_REFCLI","EE9_CODNOR","EE9_VM_NOR","EE9_PERCOM"}

          If EECFlags("CAFE") .And. Ap104VerPreco()
            aAdd(aItemEnchoice,"EE9_PRECO2")
            aAdd(aItemEnchoice,"EE9_PRECO3")
            aAdd(aItemEnchoice,"EE9_PRECO4")
            aAdd(aItemEnchoice,"EE9_PRECO5")
         Endif
      
         aItemBrowse := ArrayBrowse("EE9","WorkIp")
         x := aScan(aItemBrowse,{|x| AllTrim(x[3]) == AllTrim(AvSx3("EE9_PRECO", AV_TITULO))})
         aAdd(aItemBrowse, Nil)
         aIns(aItemBrowse, x)
         aItemBrowse[x] := {{|| TRANSF(WorkIp->EE9_SLDINI,AvSx3("EE9_SLDINI",AV_PICTURE)) },"",AvSx3("EE9_SLDINI",AV_TITULO)}
         
      Else 
         aCpos:={{"EEC_PREEMB",{|| AE109Valid("EEC_PREEMB")},{||nSelecao == 3},.T.,},; //Campos da Capa
                 {"EEC_DTPROC",,,,},;
                 {"EXL_NUMRV" ,,{||.F.},,},;
                 {"EEC_STTDES",,{||.F.},,},;
                 {"EEC_FORN"  ,,{||.F.},,},;
                 {"EEC_FOLOJA",,{||.F.},,},;
                 {"EEC_FORNDE",,{||.F.},,},;
                 {"EE9_PRECO",{|| Ae109Valid("PRECO_RV")},{||lWhen},.T.,STR0096},; //STR0096	"Preço Un."
                 {"EEC_TOTPED",,{||.F.},.T.,STR0094},; //STR0094	"Preço Total"
                 {"EEC_TOTITE",,{||.F.},.T.,STR0095},; //STR0095	"Quantidade"
                 {"EEC_CONDPA",{|| AE109Valid("EEC_CONDPA")},{||lWhen},.T.,},;
                 {"EEC_DIASPA",,,.T.,},;
                 {"EEC_DESCPA",,{||.F.},.T.,},;
                 {"EEC_DSCCOM",,{||.F.},,},;
                 {"EEC_DTEFE" ,,{|| nSelecao <> EXCLUIR .And. nSelecao <> VISUALIZAR},,},;
                 {"EEC_OBS"   ,,{||lWhen},,}}

         aObrigatorios := {"EEC_PREEMB",;
                           "EEC_CONDPA"}
         aItemBrowse := ArrayBrowse("EE9","WorkRv")

      EndIf
   EndIf

End Sequence

Return Nil

/*
Funcao      : 
Parametros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 
Revisao     :
Obs.        :
*/
*--------------------------*
Function AE109Valid(cCampo)
*--------------------------*
Local lRet := .T., aOrd, i
Begin Sequence

If ValType(cCampo) <> "C"
   cCampo := AllTrim(Substr(ReadVar(),4))
EndIf

Do Case

   Case cCampo == "VAL_OK"
       If !Ae109Valid("OBRIGATORIOS")
          lRet := .F.
          Break
       EndIf
       If (cStatus <> ST_WR .And. !AE109Valid("ITENS")) .Or. (cStatus == ST_WR .And. !AE109Valid("RV"))
          lRet := .F.
          Break
       EndIf
       If nSelecao == INCLUIR .And. M->EXL_TIPOWO <> ST_WR 
          If IsProcOffShore(M->EEC_PEDREF,OC_PE,cFilEx)
             If !Ae109GetEmbBr()
                lRet := .F.
                Break
             EndIf
          EndIf
       EndIf
       If nSelecao == EXCLUIR
          aOrd := SaveOrd("EEQ")
          EEQ->(DbSetOrder(1))
          If EEQ->(DbSeek(xFilial("EEQ")+M->EEC_PREEMB))
             While EEQ->(!Eof() .And. EEQ_PREEMB == M->EEC_PREEMB)
                If !Empty(EEQ->EEQ_PGT)
                   MsgInfo(STR0053, STR0051)//"O processo não pode ser excluido porque possui parcelas de câmbio liquidadas." ### "Alerta"
                   lRet := .F.
                   RestOrd(aOrd)
                   Break
                EndIf
                EEQ->(DbSkip())
             EndDo
          EndIf
          RestOrd(aOrd)
          If !MsgYesNo(STR0040, STR0050) //"Confirma exclusão do processo de Wash-Out?" ### "Atenção"
             lRet := .F.
             Break
          EndIf
       EndIf

   Case cCampo == "EEC_DTEFE"
      //lWhen := Ae109Valid("WHEN")
      If !Empty(M->EEC_DTEFE)
         If M->EEC_DTEFE < M->EEC_DTPROC
            MsgInfo(STR0015, STR0051) //"A data de efetivação deve ser superior a data do pedido." ### "Alerta"
            lRet := .F.
            Break
         EndIf
         If !AE109Valid("OBRIGATORIOS")
            lRet := .F.
            Break
         EndIf
         If cStatus == ST_WA .And. !Empty(M->EEC_DTEFE) .And. !Ae109ChkPreco()
            lRet := .F.
            Break
         EndIf
      Else
         aOrd := SaveOrd("EEQ")
         EEQ->(DbSetOrder(1))
         If EEQ->(DbSeek(xFilial("EEQ")+M->EEC_PREEMB))
            While EEQ->(!Eof() .And. EEQ_PREEMB == M->EEC_PREEMB)
               If !Empty(EEQ->EEQ_PGT)
                  MsgInfo(STR0041, STR0051)//"A data de efetivação não pode ser alterada porque o embarque possui parcelas de câmbio liquidadas." ### "Alerta"
                  lRet := .F.
                  RestOrd(aOrd)
                  Break
               EndIf
               EEQ->(DbSkip())
            EndDo
         EndIf
         RestOrd(aOrd)
         M->EEC_STATUS := M->EXL_TIPOWO
         M->EEC_STTDES := Tabela("YC", M->EXL_TIPOWO)
         If(cStatus == ST_WR, AE109ChkRv(M->EEC_PEDREF),)
         nRecnoIp := WorkIp->(Recno())
         WorkIp->(DbGoTop())
         While WorkIp->(!Eof())
            If Empty(WorkIp->EE9_DTFIX)
               WorkIp->EE9_PRECO := 0
            EndIf
            WorkIp->(DbSkip())
         EndDo
         WorkIp->(DbGoTo(nRecnoIp))
      EndIf

   Case cCampo == "EE9_SLDINI"
      If !Positivo(M->EE9_SLDINI) .Or. !(M->EE9_SLDINI > 0)
         MsgInfo(STR0042, STR0051)//"A quantidade deve ser maior que zero." ### "Alerta"
         lRet := .F.
         Break
      EndIf
      EE8->(DbSetOrder(1))
      EE8->(DbSeek(xFilial("EE8")+M->EEC_PEDREF+M->EE9_SEQUEN))
      If M->EE9_SLDINI > EE8->EE8_SLDATU + WorkIp->WP_OLDINI
         MsgInfo(STR0016,STR0051) //"Quantidade superior ao saldo disponível." ### "Alerta"
         lRet := .F.
         Break
      EndIf
   
   Case cCampo == "EE9_DIFERE"
      EE8->(DbSetOrder(1))
      If EE8->(DbSeek(xFilial("EE8")+M->EEC_PEDREF+M->EE9_SEQUEN))
         If(M->EXL_TIPOWO == "G" .And. EE8->EE8_DIFERE >= M->EE9_DIFERE, (MsgInfo(StrTran(STR0054, "###", AllTrim(Transf(EE8->EE8_DIFERE,AVSX3("EE8_PRECO",AV_PICTURE)))),STR0051),lRet := .F.),) //"O diferencial deve ser superior ao diferencial do item no pedido." ### "Alerta"
         If(M->EXL_TIPOWO == "H" .And. EE8->EE8_DIFERE <= M->EE9_DIFERE, (MsgInfo(StrTran(STR0055, "###", AllTrim(Transf(EE8->EE8_DIFERE,AVSX3("EE8_PRECO",AV_PICTURE)))),STR0051),lRet := .F.),) //"O diferencial deve ser inferior ao diferencial do item no pedido." ### "Alerta"
         If(M->EXL_TIPOWO == "I" .And. EE8->EE8_DIFERE <> M->EE9_DIFERE, (MsgInfo(StrTran(STR0056, "###", AllTrim(Transf(EE8->EE8_DIFERE,AVSX3("EE8_PRECO",AV_PICTURE)))),STR0051),lRet := .F.),) //"O diferencial deve ser igual ao diferencial do item no pedido." ### "Alerta"
      EndIf

   Case cCampo == "EE9_PRECO"
      EE8->(DbSetOrder(1))
      If EE8->(DbSeek(xFilial("EE8")+M->EEC_PEDREF+M->EE9_SEQUEN))
         If(M->EXL_TIPOWO == ST_WI .And. EE8->EE8_PRECO >= M->EE9_PRECO, (MsgInfo(StrTran(STR0017, "###", AllTrim(Transf(EE8->EE8_PRECO,AVSX3("EE8_PRECO",AV_PICTURE)))),STR0051),lRet := .F.),) //"O preço deve ser superior ao preço do item no pedido." ### "Alerta"
         If(M->EXL_TIPOWO == ST_WO .And. EE8->EE8_PRECO <= M->EE9_PRECO, (MsgInfo(StrTran(STR0018, "###", AllTrim(Transf(EE8->EE8_PRECO,AVSX3("EE8_PRECO",AV_PICTURE)))),STR0051),lRet := .F.),) //"O preço deve ser inferior ao preço do item no pedido." ### "Alerta"
         If(M->EXL_TIPOWO == ST_WN .And. EE8->EE8_PRECO <> M->EE9_PRECO, (MsgInfo(StrTran(STR0019, "###", AllTrim(Transf(EE8->EE8_PRECO,AVSX3("EE8_PRECO",AV_PICTURE)))),STR0051),lRet := .F.),) //"O preço deve ser igual ao preço do item no pedido." ### "Alerta"
      EndIf

      
   Case cCampo == "OBRIGATORIOS"
      For i := 1 To Len(aObrigatorios)
         If Empty(&("M->" + aObrigatorios[i]))
            lRet := .F.
            MsgInfo(StrTran(STR0020, "###", AvSx3(aObrigatorios[i], AV_TITULO)),STR0052) //"O Campo: ### não foi informado."
            Break
         EndIf
      Next
      
   Case cCampo == "ITEM"
      If !AE109Valid("EE9_SLDINI")
         lRet := .F.
         Break
      EndIf
      If Empty(WorkIp->EE9_DTFIX)
         If Empty(M->EE9_MESFIX)
            MsgInfo(STR0057, STR0052)//"Favor informar o mês de fixação"
            lRet := .F.
            Break
         EndIf
      Else
         If !AE109Valid("EE9_PRECO")
            lRet := .F.
            Break
         EndIf
      EndIf
      
   Case cCampo == "ITENS"
      nRecnoWorkIp := WorkIp->(Recno())
      WorkIp->(DbGoTop())
      While WorkIp->(!Eof())
         If WorkIp->WP_FLAG == cMarca
            WorkIp->(DbGoTo(nRecnoWorkIp))
            Break
         EndIf
         WorkIp->(DbSkip())
      EndDo
      MsgInfo(STR0043,STR0050)//"Não há itens vinculados ao processo." ### "Atenção"
      lRet := .F.
      
   Case cCampo == "EEC_CONDPA"
      If !Empty(M->EEC_CONDPA)
         SY6->(DbSetOrder(1))
         SY6->(DbSeek(xFilial("SY6")+M->EEC_CONDPA))
         If SY6->Y6_TIPO <> "2"
           MsgInfo(STR0022,STR0051) //"A condição de pagamento deve ser do tipo 'A Vista'." ### "Alerta"
           lRet := .F.
           Break
         EndIf
      EndIf
   
   Case cCampo == "EEC_PREEMB"
      If !Empty(M->EEC_PREEMB)
        If !ExistChav("EEC")
            lRet := .F.
            Break
         EndIf
      EndIf
      
   Case cCampo == "WHEN"
      If !Empty(M->EEC_DTEFE) .Or. (nSelecao <> INCLUIR .And. !Empty(EEC->EEC_DTEMBA)) .Or. nSelecao == EXCLUIR .Or. nSelecao == VISUALIZAR
         lRet := .F.
         Break
      EndIf
   
   Case cCampo == "RV"
      AE109ChkRv(M->EEC_PEDREF)
      If M->EE9_PRECO == 0
         MsgInfo(STR0044,STR0050)//"Favor informar um preço válido" ### "Atenção"
         lRet := .F.
         Break
      EndIf
      If !IsVazio("WorkRv") .And. !Empty(M->EEC_DTEFE)
         MsgInfo(STR0045, STR0051)//"Não é possível efetivar o Wash-Out porque o R.V. possui quantidade vinculada e não embarcada." ### "Alerta"
         lRet := .F.
         Break
      EndIf
   
   Case cCampo == "SLDRV"
      EEY->(DbSetOrder(1))
      EEY->(DbSeek(xFilial("EEY")+cNumRv))
      If !(AE109ChkRv(EEY->EEY_PEDIDO) > 0)
         MsgInfo(STR0046,STR0051)//"O R.V. escolhido não possui saldo disponível para realização de Wash-Out" ### "Alerta"
         lRet := .F.
         Break
      EndIf
      
   Case cCampo == "PRECO_RV"
      If Positivo(M->EE9_PRECO)
         nRecnoIp := WorkIp->(Recno())
         WorkIp->(DbGoTop())
         While WorkIp->(!Eof())
            WorkIp->EE9_PRECO := M->EE9_PRECO
            WorkIp->(DbSkip())
         EndDo
         Ae100PrecoI()
         WorkIp->(DbGoTo(nRecnoIp))
      Else
         lRet := .F.
         Break
      EndIf
   
   Case cCampo == "EEC_PEDREF"
      aOrd := SaveOrd({"EE7", "EE8"})
      EE7->(DbSetOrder(1))
      If !Empty(M->EEC_PEDREF) .And. !ExistCpo("EE7")
         lRet := .F. 
         Break
      ElseIf Empty(M->EEC_PEDREF)
         Break
      EndIf
      
      EE7->(DbSeek(xFilial("EE7")+M->EEC_PEDREF))
      lRet := .F.
      EE8->(DbSetOrder(1))
      If EE8->(DbSeek(xFilial("EE8")+M->EEC_PEDREF))
         While EE8->(!Eof() .And. EE8_PEDIDO == M->EEC_PEDREF)
            If EE8->EE8_SLDATU > 0
               lRet := .T.
            EndIf
            EE8->(DbSkip())
         EndDo
      EndIf
      If !lRet
         MsgInfo(STR0011,STR0052) //"Não há itens com saldo disponível" ### "Aviso"
         Break
      EndIf

      M->EEC_IMPORT := EE7->EE7_IMPORT
      M->EEC_IMLOJA := EE7->EE7_IMLOJA
      M->EEC_IMPODE := EE7->EE7_IMPODE
      M->EEC_ENDIMP := EE7->EE7_ENDIMP
      M->EEC_END2IM := EE7->EE7_END2IM
      M->EEC_CLIENT := EE7->EE7_CLIENT
      M->EEC_CLLOJA := EE7->EE7_CLLOJA
      M->EEC_CLIEDE := CriaVar("EEC_CLIEDE")
      M->EEC_FORN   := EE7->EE7_FORN
      M->EEC_FOLOJA := EE7->EE7_FOLOJA
      M->EEC_FORNDE := CriaVar("EEC_FORNDE")
      //Só copia a condição de pagamento se a mesma for do tipo "A Vista".
      SY6->(DbSetOrder(1))
      If SY6->(DbSeek(xFilial("SY6")+EE7->EE7_CONDPA)) .And. SY6->Y6_TIPO == "2"
         M->EEC_CONDPA := EE7->EE7_CONDPA
         M->EEC_DIASPA := EE7->EE7_DIASPA
         SY6->(DbSetOrder(1))
         SY6->(DbSeek(xFilial("SY6")+M->EEC_CONDPA+STR(M->EEC_DIASPA,3,0)))
         M->EEC_DESCPA := MSMM(SY6->Y6_DESC_P,60)
      Else
         M->EEC_CONDPA := CriaVar("EEC_CONDPA")
         M->EEC_DIASPA := CriaVar("EEC_DIASPA")
         M->EEC_DESCPA := CriaVar("EEC_DESCPA")
      EndIf
      //Grava na Work de itens os itens do processo para marcação
      MsAguarde({|| MsProcTxt(STR0035), AE109CtGrvWk()},STR0007)//"Obtendo dados do processo." ### "Wash-Out Contrato"
      M->EEC_DSCCOM := EECResCom()
      
End Case

End Sequence

Return lRet

/*
Funcao      : Ae109ChkPreco()
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Obter o preço dos itens sem preço fixado com base na cotação da bolsa informada
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 26/04/06 - 10:00
Revisao     :
Obs.        :
*/
*-----------------------*
Function Ae109ChkPreco()
*-----------------------*
Local lRet := .T.
Local aOrd := SaveOrd({"EE7"})
Local aItens := {}
Local nRecnoIp := WorkIp->(Recno()), nInc

Begin Sequence
   EE7->(DbSetOrder(1))
   EX7->(DbSetOrder(2))

   WorkIp->(DbGoTop())
   While WorkIp->(!Eof())
      If EE7->(DbSeek(xFilial()+WorkIp->EE9_PEDIDO))
         If (nCot := WorkIp->(BuscaVlCot(EE9_MESFIX,EE7->EE7_CODBOL,dDatabase,EE9_UNPRC))) > 0
            If (nCot := nCot + WorkIp->(WK_DIFERE - EE9_DIFERE)) > 0
               WorkIp->EE9_PRECO := nCot
               aAdd(aItens, WorkIp->(Recno()))
            Else
               MsgInfo(STR0061, STR0050)// "O diferencial informado torna o preço do item negativo. Não será possível prosseguir." ### "Atenção"
               lRet := .F.
               Break
            EndIf
         Else
            lRet := .F.
            Exit
         EndIf
      EndIf
      WorkIp->(DbSkip())
   EndDo
   If !lRet
      For nInc := 1 To Len(aItens)
         WorkIp->(DbGoTo(aItens[nInc]))
         WorkIp->EE9_PRECO := 0
      Next
      MsgInfo(STR0060, STR0050)//"Não é possível efetivar o Wash-Out porque um dos itens marcados sem fixação de preço não possui cotação cadastrada para a bolsa e período informados." ### "Atenção"
   Else
      Ae100PrecoI(.T.)
      EECTotCom(OC_EM,,.t.)
   EndIf

End Sequence
RestOrd(aOrd, .T.)
WorkIp->(DbGoTo(nRecnoIp))
oMsSelect:oBrowse:Refresh()

Return lRet

/*
Funcao      : AE109Works()
Parametros  : cOpc   - Ação desejada:
                       "ZAP"    -> Apaga o conteúdo das Works
                       "CREATE" -> Cria as Works
                       "ERASE"  -> Apaga o arquivo das Works
              aWorks - Array com as definições das Works.
              Ex.: {{cAliasWk,cAlias,"cNomArq",aHeader,aCampos,aSemSx3,aIndex,}}
                   cAliasWk  -> Alias da Work a ser gerada
                   cAlias    -> Alias do arquvo no qual a work será baseada
                   "cNomArq" -> String com o nome da variável que irá guardar o nome do arquivo gerado
                   aHeader   ->
                   aCampos   -> 
                   aSemSx3   -> Campos que não constam no dicionário de dados
                   aIndex    -> Indices a ser adionados na Work, Ex: {{"cNomArqIndex",cIndice}}
                   aBlocks   -> Array com codeblocks a serem executados
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 10:00
Revisao     :
Obs.        :
*/
*--------------------------------*
Function AE109Works(cOpc, aWorks)
*--------------------------------*
Local cWkAlias, cAlias, cNomArq, i, x
Private aHeader := {}, aCampos := {}, aSemSx3 := {}, aIndex := {}, aBlocks := {}

Begin Sequence

   For i := 1 To Len(aWorks)
      cWkAlias := aWorks[i][1]
      cAlias   := aWorks[i][2]
      cNomArq  := aWorks[i][3]
      If(ValType(aWorks[i][4]) == "A",aHeader := aWorks[i][4],)
      If(ValType(aWorks[i][5]) == "A",aCampos := aWorks[i][5],aCampos := Array((cAlias)->(FCOUNT())))
      If(ValType(aWorks[i][6]) == "A",aSemSx3 := aWorks[i][6],)
      If(ValType(aWorks[i][7]) == "A",aIndex  := aWorks[i][7],)
      If(ValType(aWorks[i][8]) == "A",aBlocks := aWorks[i][8],)

      Do Case
         Case cOpc == "CREATE"
            If Select(cWkAlias) == 0
               &cNomArq := E_CRIATRAB(cAlias,aSemSx3,cWkAlias)
               For x := 1 To Len(aIndex)
                  If x == 1
                     cNomArqIndex := cNomArq
                  Else
                      cNomArqIndex := aIndex[x][1]
                     &cNomArqIndex := CriaTrab(,.f.)
                  EndIf
                  cExpr := aIndex[x][2]
                  
                  IndRegua(cWkAlias,&cNomArqIndex+TEOrdBagExt(),cExpr,"AllwaysTrue()",;
                  "AllwaysTrue()",STR0023) //"Processando Arquivo Temporario ..."

                  OrdListAdd(&cNomArq+TEOrdBagExt(),&cNomArqIndex+TEOrdBagExt())
                  
               Next

               For x := 1 To Len(aBlocks)
                  Eval(aBlocks[x])
               Next
            EndIf
      
         Case cOpc == "ZAP"
            If Select(cWkAlias) > 0
               (cWkAlias)->(AvZap())
               For x := 1 To Len(aBlocks)
                  Eval(aBlocks[x])
               Next
            EndIf
               
         Case cOpc == "ERASE"
            If Select(cWkAlias) > 0
               (cWkAlias)->(E_EraseArq(&cNomArq))
               For x := 2 To Len(aIndex)
                  cNomArqIndex := aIndex[x][1]
                  FErase(cNomArqIndex+TEOrdBagExt())
               Next
               For x := 1 To Len(aBlocks)
                  Eval(aBlocks[x])
               Next
            EndIf
            
      EndCase

   Next
   
End Sequence

Return Nil

/*
Funcao      : Ae109Gets
Parametros  : oDlg, aPos, aCpos
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 
Revisao     : Julio de Paula Paz - 13/11/2006 - 10:00 - Inclusão dos tratamentos, quando a montagem da tela
                                                        for baseada em variáveis definidas pelo programador,
                                                        que não existem no dicionário de dados.
Obs.        :
*/
*-----------------------------------*
Function Ae109Gets(oDlg, aPos, aCpos)
*-----------------------------------*

Local nLinSay  := 18,  nLinGet  := 07,;
      nCol1Say := 10,  nCol1Get := 40,;
      nCol2Say := 285, nCol2Get := 180,;
      i
Local lCol2 := .F., lInc := .T.  
Local aOrd := SaveOrd({"SX3"}), lDicionario, nLen := 0,nTamSay 

Private aAvSx3

oSbox := TScrollBox():New( oDlg, aPos[1], aPos[2], aPos[3], aPos[4],.T.,.F.,.T. )
aEval(aCpos, {|x| If(x[5]<> Nil .And. Len(x[5]) > nLen,nLen:=Len(x[5]),Nil)})                                                                                                

SX3->(DbSetOrder(2))
For i := 1 To Len(aCpos)
    If SX3->(DbSeek(aCpos[i][1]))
       lDicionario := .T.
       aAvSx3  := AvSx3(aCpos[i][1])
       cVar    := ("M->"+aCpos[i][1])
       bGet    := &("{|u| If(pCount() > 0, M->" + aCpos[i][1] + " := u, M->" + aCpos[i][1] + ")}")
       nCol1Get := 40
       nTamSay := 70
    Else
       lDicionario := .F.
       cVar    := (aCpos[i][1])
       bGet    := &("{|u| If(pCount() > 0, " + aCpos[i][1] + " := u, " + aCpos[i][1] + ")}")    
       nTamSay := 125
       //nCol1Get := (nLen * 2) 
       nCol1Get := (nLen * 3) //ER - 12/12/2007 
    EndIf

	If ValType(aCpos[i][4]) == "L"
	   lObrigat := aCpos[i][4]
	Else
	   lObrigat := .F.
	EndIf

    If lDicionario
	   If (!Empty(aAvSx3[6]),cPicture := aAvSx3[6],cPicture := Nil)
	Else
	   If (!Empty(aCpos[i][10]),cPicture := aCpos[i][10],cPicture := Nil)
	EndIf   
	If !Empty(aCpos[i][2])
	   bValid := aCpos[i][2]
	Else
	   If lDicionario
	      If (!Empty(aAvSx3[7]),bValid := aAvSx3[7], bValid := Nil)
	   Else
	      bValid := Nil
	   EndIf   
	EndIf
	If !Empty(aCpos[i][3])
	   bWhen := aCpos[i][3]
	Else
	   If lDicionario
	      If (!Empty(aAvSx3[13]),bWhen := aAvSx3[13], Nil)
	   Else
	      bWhen := Nil
	   EndIf   
	EndIf
	If lDicionario
       If (!Empty(aAvSx3[8]),cF3 := aAvSx3[8],cF3 := Nil)
    Else   
       If (!Empty(aCpos[i][09]),cF3 := aCpos[i][09],cF3 := Nil)
    EndIf
    If ValType("aCpos[i][6]") == "L" .And. aCpos[i][6] == .F.
       bTrigger := Nil
    Else
       bTrigger := &("{|| AvExecGat('" + aCpos[i][1] + "')}")
    EndIf
    
    If lDicionario
       If(ValType(aCpos[i][5]) == "C", cTitulo := aCpos[i][5], cTitulo := aAvSx3[5])
    Else
       If(ValType(aCpos[i][5]) == "C", cTitulo := aCpos[i][5], cTitulo := STR0097)//	STR0097	"Sem Titulo"
    EndIf
    
    If lDicionario
       If aAvSx3[2] == "D"
          nSize := 50
       ElseIf aAvSx3[2] == "M"
          nSize := 170
       Else
          nSize := aAvSx3[3]*4
       EndIf
    Else
       nSize := aCpos[i][8]
    EndIf         

    If nSize > 80 .And. nSize < 120
       nSize := 80
    ElseIf nSize > 240
       nSize := 240
    EndIf
                    
    nHeight := 07
    /*If aAvSx3[2] <> "M"
       nHeight := 07
    Else
       nHeight := 42
    EndIf*/
    If lDicionario
       If(aAvSx3[2] == "M",nHeight := 42,Nil)
    Else
       If ValType(aCpos[i][7]) == "L" .And. (aCpos[i][7])
          nHeight := 42
       EndIf
    EndIf
        
    If lCol2 .And. nSize <= 80
       nColSay := nCol2Say
       nColGet := nCol2Get
       lCol2 := .F.
       lInc := .T.
    Else                  
       If lCol2
          nLinSay += 26
          nLinGet += 13
          lCol2 := .F.
       EndIf
       nColSay := nCol1Say
       nColGet := nCol1Get
       If lDicionario .And. (nSize <= 80 .Or. aAvSx3[2] == "D")
          lCol2 := .T.
          lInc := .F.
       Else
          lInc := .T.
       EndIf
    EndIf

    
            
    If If(lDicionario,(aAvSx3[2] <> "M"),If((ValType(aCpos[i][7]) == "L" .And. !(aCpos[i][7])) .Or. Empty(aCpos[i][7]),.T.,.F.))
       &("o"+aCpos[i][1]) := TGet():New(nLinGet,nColGet,bGet, oSbox,nSize ,nHeight,cPicture,bValid,,,,,,.T.,,,bWhen, .F., .F.,/*bTrigger*/ , .F., .F.,cF3,cVar)
    Else
       &("o"+aCpos[i][1]) := TMultiGet():New( nLinGet, nColGet, bGet,oSBox, nSize, nHeight, , .T.,,,,.T.,,,bWhen,,,,bValid,,,, )
    EndIf   
    
    oSay                 := TSay():Create(oSBox)
    oSay:cName           := "oSay" +aCpos[i][1]
    oSay:cCaption        := If(lDicionario,cTitulo,AllTrim(cTitulo))
    oSay:nLeft           := nColSay
    oSay:nTop            := nLinSay
    oSay:nWidth          := nTamSay //125
    oSay:nHeight         := 20
    oSay:lShowHint       := .F.
    oSay:lReadOnly       := .F.
    oSay:Align           := 0
    oSay:lVisibleControl := .T.
    oSay:lWordWrap       := .F.
    oSay:lTransparent    := .F.
    If lObrigat
       oSay:nClrText     := CLR_HBLUE
    EndIf
    
    If lInc
       nLinSay += 26
       nLinGet += 13
       If If(lDicionario,(aAvSx3[2] == "M"),If((ValType(aCpos[i][7]) == "L" .And. (aCpos[i][7])),.T.,.F.))
          nLinSay += 71
          nLinGet += 35
       EndIf
    EndIf

Next

RestOrd(aOrd)

Return oSBox //TDF - 13/09/2012 - Retornar objeto

  
/*
Funcao      : Ae109ChangeRecno
Parametros  : aWkChange - Array com as definições das Works a serem alteradas.
              Ex.: {cAlias, cAliasWk, cCpoRecno, cInd, cCpoChav, cDeletados, cExpUnico}
                    cAlias     -> Alias do arquivo a ser verificados os Recno´s
                    cAliasWk   -> Alias da Work onde está o campo de Recno
                    cCpoRecno  -> Nome do campo da Work que grava o Recno do registro
                    cInd       -> String com o número do indice a ser utilizado
                    cCpoChav   -> Nome do campo a ser atualizado
                    cDeletados -> Nome do array onde são guardados os Recnos dos campos deletados. Ex.:"aDeletados"
                    cExpUnico  -> Expressão usada na comparação dos registros Ex.: "EEJ_CODIGO+EEJ_OCORRE+EEJ_TIPOBC"
Retorno     : aWkChange - Atualizado com os Recnos antigos, para restauração posterior.
Objetivos   : Atualiza o campo de Recno e o campo chave em uma Work, para quando a filial foi alterada.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        : 
*/
*-----------------------------------*
Function Ae109ChangeRecno(aWkChange)
*-----------------------------------*
Local cAlias, cAliasWk, cCpoRec, cIndex, cChav, aOrd, aRecnoWkAnt, aDel, cUnico, cComp
Local i, j
For i := 1 To Len(aWkChange)
      
   cAlias   := aWkChange[i][1]
   cAliasWk := aWkChange[i][2]
   cCpoRec  := aWkChange[i][3]
   cIndex   := aWkChange[i][4]
   cCpoChav := aWkChange[i][5]
   aDel     := &(aWkChange[i][6])
   If(Len(aWkChange[i]) == 7, cUnico := aWkChange[i][7], )
   aOrd     := SaveOrd(cAlias)
   

   If Len(aWkChange[i]) == 8
      (cAliasWk)->(DbGoTop())
      aRecnoWkAnt := aClone(aWkChange[i][8])
      For j := 1 To Len(aRecnoWkAnt)
         (cAliasWk)->&(cCpoChav) := M->EEC_PREEMB
         (cAliasWk)->&(cCpoRec) := aRecnoWkAnt[j]
         (cAliasWk)->(DbSkip())
      Next
      aDel(aWkChange[i],8)
      aSize(aWkChange[i],7)
   Else   
      (cAliasWk)->(DbGoTop())
      aRecnoWkAnt := {}      
      (cAlias)->(DbSetOrder(Val(cIndex)))
      cChav := (SubStr((cAlias)->(IndexKey()),At("+",(cAlias)->(IndexKey()))+1))
      For j := 1 To Len(aDel)
         (cAlias)->(DbGoTo(aDel[j]))
         cChav := StrTran(cChav, cCpoChav, "'" + M->EEC_PREEMB + "'")
         If( ValType(cUnico) == "C", cComp := (cAlias)->&(cUnico), )
         (cAlias)->(DbSeek(xFilial(cAlias)+(cAlias)->&(cChav)))
         If ValType(cUnico) == "C" .And. (cAlias)->&(cUnico) <> cComp
            While (cAlias)->&(cUnico) <> cComp
               (cAlias)->(DbSkip())
            EndDo
         EndIf
         aDel[j] := (cAlias)->(Recno())
      Next
      (cAliasWk)->(DbGoTop())
      While (cAliasWk)->(!Eof())
         (cAliasWk)->&(cCpoChav) := M->EEC_PREEMB
         aAdd(aRecnoWkAnt, (cAliasWk)->&(cCpoRec))
         If (cAliasWk)->&(cCpoRec) <> 0
            (cAlias)->(DbSeek(xFilial(cAlias)+(cAliasWk)->&(cChav)))
            If ValType(cUnico) == "C" .And. (cAliasWk)->&(cUnico) <> (cAlias)->&(cUnico)
               While (cAlias)->&(cChav) == (cAliasWk)->&(cChav) .And. (cAliasWk)->&(cUnico) <> (cAlias)->&(cUnico)
                  (cAlias)->(DbSkip())
               EndDo
            EndIf
            (cAliasWk)->&(cCpoRec) := (cAlias)->(Recno())
         EndIf
         (cAliasWk)->(DbSkip())
      EndDo
      &(aWkChange[i][6]) := aClone(aDel)
      aAdd(aWkChange[i], aClone(aRecnoWkAnt))
   EndIf
   RestOrd(aOrd, .T.)
Next

Return aWkChange

/*
Funcao      : AE109RvWashOut
Parametros  : Nenhum.
Retorno     : Nenhum.
Objetivos   : Executar mBrowse
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*------------------------*
Function AE109RvWashOut()
*------------------------*
Private aRotina := MenuDef(ProcName()) 
Private aMemos := {{"EEC_CODMEM","EEC_OBS"}}

Private aMemoItem := {{"EE9_DESC"  ,"EE9_VM_DES"},;
                      {"EE9_QUADES","EE9_DSCQUA"}}

Private aWorks := {}
Private aWkChRecno := {}

Private cFilBr := "", cFilEx := ""

Private lIntermed := EECFlags("INTERMED")

Private cNomArq1, cNomArq2, cNomArq3, cNomArq4, cNomArq5, cNomArq6, cNomArq7, cNomArq8, cNomArq9, cNomArq10,;
        cNomArq11, cNomArq12, cNomArq13, cNomArq14, cNomArq15, cNomArq16, cNomArq17 // By JPP 11/12/2006 - 16:00

Private cStatus := ST_WR
Private cTipoProc := PC_RG
Private cArqWkEYU, aCampoEYU, lItFabric := EasyGParam("MV_AVG0138",,.F.), aItFabPos, aEYUDel,nRegFabrIt
Private lIntDesp := .F.

Begin Sequence

   //If xFilial("EEC") <> cFilBr
   If lIntermed .And. (xFilial("EEC") <> cFilBr)//RMD - 04/06/08 - A rotina pode ser executada em ambientes sem intermediação
      MsgInfo(STR0047,STR0052)//"A Rotina de Wash-Out de R.V. não está disponível para a filial Off-Shore." ### "Aviso"
      Break
   EndIf

   //Cria Arquivos Temporários
   Ae109Defs("WORKS")
   AE109Works("CREATE",aWorks)

   //Filtra a tabela EEC para mostrar somente os Embarques de Wash-Out de R.V.
   EECFilterEmb("WASHOUT-RV")

   SetMbrowse("EEC")

End Sequence

AE109Works("ERASE",aWorks) //Apaga os Arquivos Temporários
//Apaga o Filtro
EECFilterEmb()

Return Nil

/*
Funcao      : Ae109GetNmRv()
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Obter o número do R.V. a ser realizado o Wash-Out
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*----------------------*
Function Ae109GetNmRv()
*----------------------*
Local aOrd  := SaveOrd({"EE7","EE8"})
Local lOk := .F.
Local bOk := {|| If(Eval(bValid),(lOk := .T., oDlg:End()),)} 
Local bCancel := {|| oDlg:End()} 
Local bValid := {|| If((Eval(bValidRV) .And. Eval(bValidSld)),.T.,.F.)}
Local bValidRV  := {|| If(!Empty(cNumRV),.T.,(MsgInfo(STR0048,STR0050),.F.)) }//"O número do R.V. não foi informado." ### "Atenção"
Local bValidSld := {|| Ae109Valid("SLDRV") }
Local oDlg
Local lRet := .F.
Local nSaldo
Private cNumRv := Space(AVSX3("EEY_NUMRV",AV_TAMANHO))

Begin Sequence
   
   DEFINE MSDIALOG oDlg TITLE "Wash-Out de RV" FROM 331,360 TO 407,710 OF oMainWnd PIXEL   //655   // By JPP - 18/10/2006 - 17:00 - Correção na dimensão da tela para ambiente MDI.
    nBorda1 := (oDlg:nClientHeight - 2.5)/2   
    nBorda2 := (oDlg:nClientWidth - 2.5)/2
    oDlg:lEscClose := .F.

    @ 14,2 To 38,175  Label STR0008 Pixel //"Informações iniciais:"    //nBorda1, nBorda2 // By JPP - 18/10/2006 - 17:00 - Correção na dimensão da tela para ambiente MDI.
    @ 23,10 Say STR0049 Pixel Color CLR_HBLUE Of oDlg // "Número do RV:"
    @ 22,65 MsGet cNumRV F3 "EEY" PICTURE "@R 99/9999999" Valid (Vazio() .Or. ExistCpo("EEY")) Size 70,07 Pixel Of oDlg

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered
             
   If lOk
      EEY->(DbSetOrder(1))
      EEY->(DbSeek(xFilial("EEY")+cNumRv))
      cPedEsp := EEY->EEY_PEDIDO
     
      M->EEC_STTDES := Tabela("YC", M->EEC_STATUS := M->EXL_TIPOWO := ST_WR)
      EE7->(DbSetOrder(1))

      EE7->(DbSeek(xFilial("EE7")+cPedEsp))
      //Copia informações do R.V.
      M->EEC_PEDREF := cPedEsp
      M->EEC_DTPROC := EE7->EE7_DTPROC
      M->EEC_FORN   := EE7->EE7_FORN
      M->EEC_FOLOJA := EE7->EE7_FOLOJA
      M->EEC_FORNDE := CriaVar("EEC_FORNDE")
      
      //Só copia a condição de pagamento se a mesma for do tipo "A Vista".
      SY6->(DbSetOrder(1))
      If SY6->(DbSeek(xFilial("SY6")+EE7->EE7_CONDPA)) .And. SY6->Y6_TIPO == "2"
         M->EEC_CONDPA := EE7->EE7_CONDPA
         M->EEC_DIASPA := EE7->EE7_DIASPA
         SY6->(DbSetOrder(1))
         SY6->(DbSeek(xFilial("SY6")+M->EEC_CONDPA+STR(M->EEC_DIASPA,3,0)))
         M->EEC_DESCPA := MSMM(SY6->Y6_DESC_P,60)
      Else
         M->EEC_CONDPA := CriaVar("EEC_CONDPA")
         M->EEC_DIASPA := CriaVar("EEC_DIASPA")
         M->EEC_DESCPA := CriaVar("EEC_DESCPA")
      EndIf
      lRet := .T.
      
   EndIf
   
End Sequence

RestOrd(aOrd, .T.)

Return lRet

/*
Funcao      : AE109ChkRv()
Parametros  : cPedEsp - Número do pedido especial do R.V.
Retorno     : nSaldo  - Saldo do R.V.
Objetivos   : Verifica o saldo do R.V. e atualiza as Works.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 05/12/05 - 15:00
Revisao     :
Obs.        :
*/
*--------------------------*
Function AE109ChkRv(cPedEsp)
*--------------------------*
Local nSaldo := 0, nSeqEmb := 1, cNumRv, lItemWk := .F.
Local i, j
Begin Sequence
   If ValType(lWhen) <> "L" .Or. Empty(EEC->EEC_DTEMBA)
      EE8->(DbSetOrder(1))
      EE8->(DbSeek(xFilial("EE8")+cPedEsp))
      cNumRv := EE8->EE8_RV
      M->EXL_NUMRV := cNumRv
      nRecnoEEC := EEC->(Recno())
      EECFilterEmb()
      AE109Works("ZAP",{{"WorkRV","EE9","cNomArq15",,,,,}}) //Limpa o Arquivo Temporário
      aItRv := SI301ItRv(cNumRv)
      i := 1
      While i <= Len(aItRv)
         EE8->(DbGoTo(aItRv[i]))
         If EE8->EE8_STATUS == ST_RV
            nSaldo += EE8->EE8_SLDATU
            WorkIp->(DbGoTop())
            While WorkIp->(!Eof())
               If WorkIp->EE9_PEDIDO == EE8->EE8_PEDIDO .And. WorkIp->EE9_SEQUEN  == EE8->EE8_SEQUEN
                  lItemWk := .T.
                  Exit
              EndIf
              WorkIp->(DbSkip())
            EndDo
            If !lItemWk
               WorkIp->(DbAppend())
               WorkIp->WP_FLAG := cMarca
               WorkIp->EE9_SEQEMB := AllTrim(Str(nSeqEmb))
               nSeqEmb++
            EndIf
            For j:=1 To EE8->(FCount())
               cField := EE8->(FieldName(j))
               bGETSETEE8:=FIELDWBLOCK(cFIELD,SELECT("EE8"))
               cFIELDEE9:="EE9"+SUBSTR(ALLTRIM(cFIELD),4)
               bGETSETEE9:=FIELDWBLOCK(cFIELDEE9,SELECT("WorkIp"))
               If ( WorkIp->(FIELDPOS(cFIELDEE9))#0)
                  EVAL(bGETSETEE9,EVAL(bGETSETEE8))
               Endif
            Next j
            WorkIp->EE9_SLDINI := EE8->EE8_SLDATU
            WorkIp->WP_SLDATU := EE8->EE8_SLDATU
            WorkIp->EE9_PRECO  := M->EE9_PRECO
            WorkIp->WP_PRCRV   := EE8->EE8_PRECO
            aDel(aItRv, i)
            aSize(aItRv, Len(aItRv)-1)
         Else
            i++
         EndIf
      EndDo
      For i := 1 To Len(aItRv)
         EE8->(DbGoTo(aItRv[i]))
         nQtd := EE8->EE8_SLDINI
         EE9->(DbSetOrder(1))
         If EE9->(DbSeek(xFilial("EE9")+EE8->(EE8_PEDIDO+EE8_SEQUEN)))
            While EE9->(!Eof() .And. EE9->EE9_FILIAL == xFilial("EE9"); 
                  .And. EE9->EE9_PEDIDO == EE8->EE8_PEDIDO; 
                  .And. EE9->EE9_SEQUEN == EE8->EE8_SEQUEN)
               EEC->(DbSetOrder(1))
               EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB))
               If !Empty(EEC->EEC_DTEMBA)
                  nQtd -= EE9->EE9_SLDINI
               Else
                  WorkRv->(DbAppend())
                  AvReplace("EE9","WorkRv")
                  WorkRv->TRB_ALI_WT:= "EE9"
                  WorkRv->TRB_REC_WT:= EE9->(Recno())
               EndIf
               EE9->(DbSkip())
            EndDo
         EndIf
         WorkIp->(DbGoTop())
         While WorkIp->(!Eof())
            If WorkIp->EE9_DTFIX == EE8->EE8_DTFIX
               If Round(WorkIp->WP_PRCRV, AvSx3("EE8_PRECO4", AV_DECIMAL)) == EE8->EE8_PRECO4
                  Exit
               EndIf
            EndIf
            WorkIp->(DbSkip())
         EndDo
         If WorkIp->(!Eof())
            WorkIp->EE9_SLDINI += AVTransUnid(WorkIp->EE9_UNIDAD, EE8->EE8_UNIDAD, EE8->EE8_COD_I, nQtd, .F.)
            nSaldo += nQtd
         EndIf
      Next
      WorkIp->(DbGoTop())
      While WorkIp->(!Eof())
         If !Empty(M->EEC_DTEFE)
            WorkIp->WP_SLDATU := 0
         EndIf
         WorkIp->(DbSkip())
      EndDo
      M->EEC_TOTITE := nSaldo
      WorkRv->(DbGoTop())
      EECFilterEmb("WASHOUT-RV")
      EEC->(DbGoTo(nRecnoEEC))
   Else
      WorkIp->(DbGoTop())
      While WorkIp->(!Eof())
         nSaldo += WorkIp->EE9_SLDINI
         If Empty(M->EEC_DTEFE)
            WorkIp->WP_SLDATU := WorkIp->EE9_SLDINI
         Else
            WorkIp->WP_SLDATU := 0
         EndIf         
         WorkIp->(DbSkip())
      EndDo
   EndIf

End Sequence

Return nSaldo

/*
Funcao      : Ae109EstItRv()
Parametros  : cPedEsp -> Número do pedido especial
Retorno     : Nil
Objetivos   : Estorna o saldo do Rv nos processo aos quais o mesmo está vinculado.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/01/05 - 10:00
Revisao     :
Obs.        :
*/
*-----------------------------*
Function Ae109EstItRv(cPedEsp)
*-----------------------------*
Local aItRv := {}, aItPedEsp := {}, cNumRv, nQtd := 0, nRateio := 0
Local aOrd := SaveOrd({"EEC","EE8","EE9"})
Local nInc, i, j
Begin Sequence
   If Empty(M->EEC_DTEMBA) .Or. (nSelecao == ALTERAR .And. !Empty(EEC->EEC_DTEMBA))
      Break
   EndIf
   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial("EE8")+cPedEsp))
   cNumRv := EE8->EE8_RV
   aItRv := SI301ItRv(cNumRv)
   i := 1
   While i <= Len(aItRv)
      EE8->(DbGoTo(aItRv[i]))
      If EE8->EE8_STATUS == ST_RV
         aAdd(aItPedEsp, aItRv[i])
         aDel(aItRv, i)
         aSize(aItRv, Len(aItRv)-1)
      Else
         i++
      EndIf
   EndDo
   For i := 1 To Len(aItRv)
      EE8->(DbGoTo(aItRv[i]))
      nQtd := EE8->EE8_SLDINI
      EE9->(DbSetOrder(1))
      If EE9->(DbSeek(xFilial("EE9")+EE8->(EE8_PEDIDO+EE8_SEQUEN)))
         While EE9->(!Eof() .And. EE9->EE9_FILIAL == xFilial("EE9"); 
               .And. EE9->EE9_PEDIDO == EE8->EE8_PEDIDO; 
               .And. EE9->EE9_SEQUEN == EE8->EE8_SEQUEN)
            EEC->(DbSetOrder(1))
            EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB))
            If !Empty(EEC->EEC_DTEMBA)
               nQtd -= EE9->EE9_SLDINI
            EndIf
            EE9->(DbSkip())
         EndDo
      EndIf

      EE8->(RecLock("EE8", .F.))     
      If nQtd == EE8->EE8_SLDINI
         EE8->EE8_RV     := ""
         EE8->EE8_SEQ_RV := ""
         EE8->EE8_DTRV   := Ctod("")
         EE8->EE8_DTVCRV := Ctod("")
         dDtFix := EE8->EE8_DTFIX
         EE8->EE8_DTFIX  := Ctod("")
         nPreco := EE8->EE8_PRECO3
         EE8->EE8_PRECO  := 0
         EE8->EE8_STFIX  := ""
         EE8->EE8_MESFIX := ""
         EE8->EE8_DIFERE := 0
         EE8->EE8_QTDLOT := 0
         EE8->EE8_DTCOTA := Ctod("")
         cUnidad := EE8->EE8_UNIDAD
         cCod_I  := EE8->EE8_COD_I
         EE8->(MSUnlock())
      Else
         nRateio := (EE8->EE8_SLDINI - nQtd) / EE8->EE8_SLDINI
         EE8->EE8_SLDINI -= nQtd
         EE8->EE8_SLDATU := 0
         If Empty(EE8->EE8_ORIGV)
            EE8->EE8_ORIGV := EE8->EE8_SEQUEN
         EndIf
         EE8->EE8_QTDEM1 := (EE8->EE8_QTDEM1 * nRateio)
         EE8->EE8_PSLQTO := (EE8->EE8_PSLQTO * nRateio)
         EE8->EE8_PSBRTO := (EE8->EE8_PSBRTO * nRateio)
         
         For nInc := 1 To EE8->(FCount())
            M->&(EE8->(FieldName(nInc))) := EE8->(FieldGet(nInc))
         Next
         EE8->(MSUnlock())
         If EE8->(DbSeek(xFilial("EE8")+cPedEsp))
            While EE8->(!Eof() .And. EE8_PEDIDO == cPedEsp)
               EE8->(DbSkip())
            EndDo
            EE8->(DbSkip(-1))
            cSequen := Str((Val(EE8->EE8_SEQUEN) + 1), AvSx3("EE8_SEQUEN", AV_TAMANHO))
         Else
            cSequen := Str(1, AvSx3("EE8_SEQUEN", AV_TAMANHO))
         EndIf

         EE8->(RecLock("EE8", .T.))
         AvReplace("M", "EE8")
         EE8->EE8_PEDIDO := cPedEsp
         EE8->EE8_SEQUEN := cSequen
         nRateio := nQtd / EE8->EE8_SLDINI
         EE8->EE8_SLDINI := nQtd
         EE8->EE8_SLDATU := nQtd
         
         EE8->EE8_QTDEM1 := (EE8->EE8_QTDEM1 * nRateio)
         EE8->EE8_PSLQTO := (EE8->EE8_PSLQTO * nRateio)
         EE8->EE8_PSBRTO := (EE8->EE8_PSBRTO * nRateio)         
         
         EE8->EE8_RV     := ""
         EE8->EE8_SEQ_RV := ""
         EE8->EE8_DTRV   := Ctod("")
         EE8->EE8_DTVCRV := Ctod("")
         dDtFix := EE8->EE8_DTFIX
         EE8->EE8_DTFIX  := Ctod("")
         nPreco := EE8->EE8_PRECO
         EE8->EE8_PRECO  := 0
         EE8->EE8_STFIX  := ""
         EE8->EE8_MESFIX := ""
         EE8->EE8_DIFERE := 0
         EE8->EE8_QTDLOT := 0
         EE8->EE8_DTCOTA := Ctod("")
         cUnidad := EE8->EE8_UNIDAD
         cCod_I  := EE8->EE8_COD_I
         EE8->(MSUnlock())         
      EndIf

      For j := 1 To Len(aItPedEsp)
         EE8->(DbGoTo(aItPedEsp[j]))
         If dDtFix == EE8->EE8_DTFIX .And. nPreco == EE8->EE8_PRECO
            EE8->(RecLock("EE8", .F.))
            EE8->EE8_SLDATU += AVTransUnid(cUnidad, EE8->EE8_UNIDAD, cCod_I, nQtd, .F.)
            Exit
         EndIf
      Next
   
   Next

End Sequence

RestOrd(aOrd, .T.)

Return Nil

*----------------------------------------
//Inicio do controle de Armazéns de CAFÉ
*----------------------------------------

/*
Função     : Ae109Armazens()
Objetivos  : Criar e excluir as works da manutenção de embarques.
Parâmetros : 
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 09/12/05 às 11:36
*/
*-----------------------*
Function Ae109Armazens()
*-----------------------*
Local aCposBrowse := ArrayBrowse("EY9","WkArm")
Local oDlg, bOk, bCancel
Local lOk := .f.
Local cBackup := CriaTrab(,.f.)
Private oBrowse

Begin Sequence

   bCancel := {|| lOk := .f., oDlg:End() }
   If nSelecao <> INCLUIR .And. nSelecao <> ALTERAR
      bOk := bCancel
   Else
      bOk := {|| lOk := .t., oDlg:End() }
   EndIf

   DbSelectArea("WkArm")
   DbSetOrder(1)
   DbGoTop()
   TETempBackup(cBackup)

   Set Filter To WkArm->DBDELETE == .F.

   DbGoTop()

   oDlg  := MsDialog():New( 1,1, 27,91,STR0062,,,,,,,,oMainWnd,.F.,,,)//"Controle de Armazéns"
   // by CRF 14/10/2010 - 12:15
   aCposBrowse := AddCpoUser(aCposBrowse,"EY9","5","WkArm")	 
      oBrowse := MsSelect():New("WkArm",,,aCposBrowse,,,PosDlg(oDlg))
      oBrowse:bAval := {|| ArmazensMan(VIS_DET)}
      oBrowse:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oDlg:Activate(,,,.T.,,,{|Self|AvBar(nSelecao,oDlg,bOk,bCancel,ENCH_ADD,{|n| ArmazensMan(n) })},)
   
   Set Filter To
   
   If !lOk
      DbSelectArea("WkArm")
      AvZap()
      TERestBackup(cBackup)
      DbGoTop()
   EndIf
   
End Sequence

Return Nil

/*
Função     : ArmazensMan()
Objetivos  : Manutenção de Armazéns (Inclusão, Alteração, Exclusão e Visualização
Parâmetros : nOpc
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 09/12/05 às 14:28
*/

*-------------------------------*
Static Function ArmazensMan(nOpc)
*-------------------------------*
Local i, oDlg, bOk, bCancel, lOk := .f., cTitle := ""
Private aTela[0][0],aGets[0], aMostra, aAltera

Begin Sequence
   aMostra := EECCposEnchoice("EY9")
   DbSelectArea("WkArm")
   If nOpc == INC_DET
      aAltera := AClone(aMostra)
      For i := 1 To EY9->(FCount())
         M->&(EY9->(FieldName(i))) := CriaVar(EY9->(FieldName(i)))
      Next
   Else
      If WkArm->(BoF() .And. EoF())
         HELP(" ",1,"ARQVAZIO")
         Break
      EndIf
      
      If nOpc == ALT_DET
         aAltera := EECAClone(aMostra,"EY9_CODARM")
      Else
         aAltera := {}
      EndIf
      For i := 1 To FCount()
         M->&(FieldName(i)) := FieldGet(i)
      Next
   EndIf   
   
   bCancel := {|| lOk := .F., oDlg:End()}

   If nOpc == VIS_DET
      bOk := bCancel
   Else
      bOk := {|| If(Ae109VldArmazem(nOpc),(lOk := .T., oDlg:End()),) }
   EndIf
   
   If nOpc == INC_DET
      cTitle := STR0003//"Incluir"
   ElseIf nOpc == ALT_DET
      cTitle := STR0004//"Alterar"
   ElseIf nOpc == VIS_DET
      cTitle := STR0001//"Visualizar"
   ElseIf nOpc == EXC_DET
      cTitle := STR0005//"Excluir"
   EndIf
                                      
   //OAP 25/10/2010 - Inclusão de um campo que venha a ser criado pelo usuário
   aAltera := AddCpoUser(aAltera,"EY9","1")
   
   
   oDlg  := MsDialog():New( 1,1, 30,94,cTitle,,,,,,,,oMainWnd,.F.,,,)
   EnChoice("EY9",,4,,,,aMostra,PosDlg(oDlg),aAltera)
   oDlg:Activate(,,,.T.,,,{|Self|EnchoiceBar(oDlg,bOk,bCancel)},)
   
   If !lOk
      Break
   EndIf

   If nOpc == EXC_DET
      WkArm->DBDELETE := .T.
      oBrowse:oBrowse:Refresh()
      Break
   EndIf

   If nOpc == INC_DET
      WkArm->(DbAppend())
   EndIf
   AvReplace("M","WkArm")
   
   If nOpc == INC_DET
      ArmazensMan(nOpc)
   EndIf

End Sequence

Return Nil

/*
Função     : Ae109VldArmazem()
Objetivos  : Validação da Enchoice de Armazéns
Parâmetros : Opção
Retorno    : .T./.F.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 09/12/05 às 14:37
*/
*------------------------------*
Function Ae109VldArmazem(nOpc)
*------------------------------*
Local lRet := .t., nRec := RecNo(), cVar

Begin Sequence
   DbSelectArea("WkArm")
   If PCount() > 0 // se foi passado o nOpc
      If nOpc = INC_DET .And. DbSeek(M->EY9_CODARM)
         DbGoTo(nRec)
         MsgInfo(STR0063,STR0050)//"O armazém informado já está cadastrado."###"Atenção"
         lRet := .f.
         Break
      EndIf
   
      If !Obrigatorio(aGets,aTela)
         lRet := .f.
         Break
      EndIf
   
      If nOpc == EXC_DET .And. !MsgNoYes(STR0064,STR0050)//"Deseja excluir o Armazém?"###"Atenção"
         lRet := .f.
         Break
      EndIf
   Else
      cVar := ReadVar()
      Do Case
         Case cVar == "M->EY9_CODARM"
            
            If !Vazio()
               Posicione("SY5",1,xFilial("SY5")+M->EY9_CODARM,"Y5_COD")
               
               If SY5->(EoF())
                  MsgInfo(STR0065,STR0050)//"O Armazém informado não se encontra cadastrado."###"Atenção"
                  lRet := .f.
                  Break
                  
               ElseIf Left(SY5->Y5_TIPOAGE,1) <> "E"
                  MsgInfo(STR0066,STR0050)//"O código informado não se refere a uma empresa do tipo 'Armazém'."###"Atenção"
                  lRet := .f.
                  Break
               EndIf
            EndIf
            
            If !Vazio()
               M->EY9_DSCARM := SY5->Y5_NOME
            EndIf
            
         Case cVar == "M->EY9_CODQUA"
            If !(Vazio() .Or. ExistCpo("EXW"))
               lRet := .f.
               Break
            EndIf
            
            If !Vazio()
               M->EY9_DSCQUA := Eval({|x| SubStr(x,1,If(At(ENTER,x)>0,At(ENTER,x)-1,Len(x)))},MSMM(Posicione("EXW",1,xFilial("EXW")+M->EY9_CODQUA,"EXW_QUADES"),AvSx3("EY9_DSCQUA",AV_TAMANHO)))
            EndIf
           
         Case cVar == "M->EY9_CODPEN"
            If !(Vazio() .Or. ExistCpo("EXX"))
               lRet := .f.
               Break
            EndIf

            If !Vazio()
               M->EY9_DSCPEN := Posicione("EXX",1,xFilial("EXX")+M->EY9_CODPEN,"EXX_DSCPEN")
            EndIf
                     
      EndCase
   EndIf
End Sequence

Return lRet

/*
Função     : Ae109GrvArm
Objetivos  : Grava a tabela de armazéns de café.
Parâmetros : 
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 09/12/05 às 14:37
Revisão    : Rodrigo Mendes Diaz
*/
Function Ae109GrvArm()
Local lInc

Begin Sequence
   
   // ** JPM - 09/12/05 - Gravação do controle de armazéns
   DbSelectArea("WkArm")
   Set Filter To WkArm->DBDELETE == .T.
   
   DbGoTop()
   While !EoF()
      If WK_RECNO <> 0
         EY9->(DbGoTo(WkArm->WK_RECNO),;
               RecLock("EY9",.F.),;
               DbDelete(),;
               MsUnlock())
      EndIf
      DbSkip()
   EndDo
   
   Set Filter To WkArm->DBDELETE == .F.

   DbGoTop()
   While !EoF()
      lInc := WkArm->WK_RECNO == 0
      If !lInc
         EY9->(DbGoTo(WkArm->WK_RECNO))
      EndIf
      EY9->(RecLock("EY9",lInc))
      AvReplace("WkArm","EY9")
      EY9->(EY9_FILIAL := xFilial(),;
            EY9_PREEMB := EEC->EEC_PREEMB)
      DbSkip()
   EndDo
   
   Set Filter To
   // **
   
End Sequence

Return Nil

/*
Função     : AE109FabrIt()
Objetivos  : Efetuar a manutenção de Fabricantes para cada Item do Embarque.
Parâmetros : 
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Function AE109FabrIt(oObjPai)

Local lRet:=.T.,cOldArea:=Select(),nOpcIt:=0,oDlg2,oProcesso
Local nL1:=1.4, nL2:=2.2, nL3:=3.0, nC1:=0.8, nC2:=15, nC3:=08, nC4:=20
Local bOk := {|| nOpcIt := 1, oDlg2:End() }
Local bCancel := {|| oDlg2:End() }
Local cFabTitulo := STR0067 // "Manutenção de Dados do Fabricante para Itens do Embarque"
Local cProcesso := M->EEC_PREEMB
Local cFileBackup := CriaTrab(,.f.), aDelBak
Local oMarkEYU
Local oPanel

Private aButtonsF := {}
//Private nItFab, onItFab
Private lFaInverte := .F., cFaMarca := cMarca

Begin Sequence
   DbSelectArea("WKEYU")
   WKEYU->(dbGoTop())
   TETempBackup(cFileBackup)
   aDelBak := aClone(aEYUDel)
   
   //If Type("lConsolida") == "L" .And. lConsolida .And. !lIntegra 
   //   WKEYU->(DbSetFilter({|| EYU_PREEMB+EYU_SEQEMB == WORKGRP->(EE9_PREEMB+EE9_SEQEMB) },"EYU_PREEMB+EYU_SEQEMB =='"+WORKGRP->(EE9_PREEMB+EE9_SEQEMB)+"'"))
   //Else
      //WKEYU->(DbSetFilter(&("{|| EYU_PREEMB+EYU_SEQEMB == '"+WORKIP->(EE9_PREEMB+EE9_SEQEMB)+"' }"),"EYU_PREEMB+EYU_SEQEMB =='"+WORKIP->(EE9_PREEMB+EE9_SEQEMB)+"'"))
      WKEYU->(DbSetFilter(&("{|| WKEYU->EYU_PREEMB == '"+WORKIP->EE9_PREEMB+"' .AND. WKEYU->EYU_SEQEMB == '"+WORKIP->EE9_SEQEMB+"' }"),"{|| WKEYU->EYU_PREEMB == '"+WORKIP->EE9_PREEMB+"' .AND. WKEYU->EYU_SEQEMB == '"+WORKIP->EE9_SEQEMB+"' }"))
   //EndIf
   WKEYU->(dbGoTop())
 
   nOpcIt := 0
   nItFab := ContaItFab()
   
   //TRP - 29/10/10 - Manutencão de Notas Fiscais
   If ChkFile("EWI")  
      Aadd(aButtonsF,{"NOTE" ,{||AE109NfFabr()},STR0098}) //	STR0098	"Notas Fiscais" 
   Endif
   
   Define MsDialog oDlg2 Title cFabTitulo From 9,0 TO 30,110 OF oMainWnd   //oObjPai    // 28,70
      
      oPanel:= TPanel():New(0,0, "", oDlg2,, .T., ,,,0,0,,.T.)
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ nL1,nC1 Say STR0013 Of oPanel// "Nro. Processo"
      @ nL1,nC2 Say STR0068 Of oPanel // "Total Itens"

      @ nL1,nC3 MsGet oProcesso Var cProcesso When .F. Size 50,7 RIGHT Of oPanel
      @ nL1,nC4 MsGet onItFab    Var nItFab   When .F. Size 50,7 RIGHT Of oPanel

      oMarkEYU:= MsSelect():New("WKEYU",,,aCampoEYU,@lFaInverte,@cFaMarca,aItFabPos,,, oPanel)
      oMarkEYU:bAval := {|| IF(Str(nSelecao,1) $ (Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1)),AE109ITFMAN(VIS_DET,oMarkEYU),AE109ITFMAN(ALT_DET,oMarkEYU)) }
      oMarkEYU:oBrowse:Align := CONTROL_ALIGN_BOTTOM
   Activate MsDialog oDlg2 On Init ;                                                     
       AVBar(If(Empty(M->EE9_ATOCON),nSelecao,VISUALIZAR),oDlg2,bOk,bCancel,ENCH_ADD,{|opc| AE109ITFMAN(opc,oMarkEYU)},,aButtonsF) Centered

   
   WKEYU->(DbClearFilter())   
   If nOpcIt == 0 //Cancelar
      DbSelectArea("WKEYU")
      AvZap()
      TERestBackup(cFileBackup)
      aEYUDel := aClone(aDelBak)
   EndIf
   
   //E_EraseArq(cFileBackup)
   
End Sequence

dbselectarea(cOldArea)
//SetDlg(oObjPai)//RMD - Seta o foco na Dialog anterior (tela do item)
Return lRet
   
/*
Funcao      : AE109ITFMAN(nTipoITFAB,oObjMark)
Parametros  : nTipoITFAB := INC_DET/VIS_DET/ALT_DET/EXC_DET
              oObjMark := Objeto MsSelect.
Retorno     : .T. 
Objetivos   : Permitir manutencao de Fabricantes para itens de Embarque
Autor       : Julio de Paula Paz
Data/Hora   : 14/11/2007 - 14:00
Revisao     :
Obs.        :
*/
Static Function AE109ITFMAN(nTipoItFab,oMarkEYU)
   
Local lRet:=.T.,cOldArea:=Select(),oDlg3,nOpcIt:=0
Local nRecOld := WKEYU->(RecNo())
Local cTitItFab := STR0069 // "Manutenção Itens dos Dados do Fabricante"
Local aItAltera := {}, nI:= 1
Local aEYUEnchoice := {}        
Local bIt_OK := {||nOpcIt:=1,oDlg3:End()}  
Local bIt_Cancel := {||nOpcIt:=0,oDlg3:End()}

Private oItMsmGet , aFabButtons := {}, nRecnoIt

Private aTela[0][0],aGets[0],aHeader[0]
 
Begin Sequence
   
   If nTipoItFab <> INC_DET
      If WKEYU->(Eof() .And. Bof())
         Help(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
         Break
      EndIf
   EndIf
 
   aEYUEnchoice := {"EYU_TIPO","EYU_FABR","EYU_FA_LOJ","EYU_FA_DES","EYU_CNPJ","EYU_UF","EYU_ATOCON","EYU_SEQED3",;
                    "EYU_PROD","EYU_VM_DES","EYU_POSIPI","EYU_NCMDES","EYU_NCM_UM","EYU_QTD", "EYU_UMPROD",;
                    "EYU_QTDPRO","EYU_MOEDA","EYU_VALOR","EYU_DTNF"}
                    
   If EYU->(FieldPos("EYU_VLSCOB")) > 0
      AADD(aEYUEnchoice,"EYU_VLSCOB")
   Endif
   
   If EYU->(FieldPos("EYU_PESO")) > 0
      AADD(aEYUEnchoice,"EYU_PESO")
   Endif
   
   If EYU->(FieldPos("EYU_OBS")) > 0
      AADD(aEYUEnchoice,"EYU_OBS")
   Endif

   If EYU->(FieldPos("EYU_TPAC")) > 0
      AADD(aEYUEnchoice,"EYU_TPAC")
   Endif
   
   aItAltera := aClone(aEYUEnchoice)
   
   IF nTipoItFab==INC_DET
      WKEYU->(DbGoBottom())
      WKEYU->(DbSkip())
   EndIf
   
   nRecnoIt:=WKEYU->(Recno())  
   
   For nI := 1 To WKEYU->(FCount())
      M->&(WKEYU->(FieldName(nI))) := WKEYU->(FieldGet(nI))
   Next nInc
     
   M->EYU_PREEMB := WorkIP->EE9_PREEMB //M->EE9_PREEMB
   M->EYU_SEQEMB := WorkIP->EE9_SEQEMB //M->EE9_SEQEMB
   //OAP 22/10/2010 - Inclusão de um campo que venha a ser criado pelo usuário
   aItAltera := AddCpoUser(aItAltera,"EYU","1")
     
   Define MsDialog oDlg3 Title cTitItFab From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel
      aPos := PosDlg(oDlg3)
      oItMsmGet := MsMGet():New("EYU", , 3, , , , aEYUEnchoice,  aPos, aItAltera, IIF(STR(nTipoItFab,1)$Str(VIS_DET,1)+"/"+Str(EXC_DET,1),3,2),,,,oDlg3)                                                                                                                                                  
             
      oItMsmGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT
      oDlg3:lMaximized := .T.   
   Activate MsDialog oDlg3 On Init EnchoiceBar(oDlg3,{|| IIf(AE109VlFabr("TELA",nTipoItFab),Eval(bIt_OK),)} ,bIt_Cancel,,aFabButtons)
   
   IF nOpcIt == 1 // ok
      IF nTipoItFab == INC_DET
         WKEYU->(DbAppend())
         nItFab++
      EndIf
      
      IF ! (Str(nTipoItFab,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1))
         If nTipoItFab <> INC_DET
            WKEYU->(DbGoTo(nRecOld))
         EndIf
         AVReplace("M","WKEYU")
      Elseif nTipoItFab == EXC_DET
         nItFab --
      EndIf
      
      oMarkEYU:oBrowse:Refresh()
      onItFab:Refresh() 
      
   Else 
      If nTipoItFab == INC_DET
         WKEYU->(DbGoTo(nRecOld))
      Endif
   EndIf

End Sequence

Dbselectarea(cOldArea)
   
Return lRet

/*
Função     : AE109VlFabr(cChamada,nTipoItFab)
Objetivos  : Efetuar a Validação de Fabricantes para cada Item do Embarque.
Parâmetros : cChamada  := Indica de onde a função foi chamada.
             nTipoItFab := indica se é uma inclusão/alteração/exclusão/Visualização.
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Function AE109VlFabr(cChamada,nTipoItFab)
Local lRet := .T., aTotais
Local nQtdTela, aTipoCnpj, nI, nValor,nValorMax, nItTaxa := BuscaTaxa(M->EYU_MOEDA,M->EYU_DTNF,,.f.)
Private nEE9Taxa //:= BuscaTaxa(M->EEC_MOEDA,WKEYU->EYU_DTNF,,.f.)
Private lQtdAdicionada := .F.
Default nTipoItFab := 99

Begin Sequence
   aTotais := AE109TotFIt()
   aTipoCnpj := Aclone(aTotais[3])
   Do Case
      Case cChamada == "TELA" .And. nTipoItFab <> EXC_DET
         if nTipoItFab == INC_DET .and. EYU->(dbsetorder(1),msseek(xFilial("EYU")+M->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3))) //! existchav("EYU",M->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON+EYU_SEQED3),1,)
            msginfo(STR0114,STR0051) //"Já existe um fabricante cadastrado com esses dados, verifique os dados do cadastro!"
            lRet := .F.
            Break
         endif

           lRet := Obrigatorio(aGets,aTela)
           // Não Permitir a inclusão de Mais de Dez itens intermediários por Item de embarque.
           If nTipoItFab == INC_DET .And. nItFab == 10
              MsgInfo(STR0070,STR0051) //"Não é Permitido Digitar mais de Dez itens intermediários por item de embarque!" ### "Atenção"
              lRet := .F.
           EndIf
           // Validação para a Data da Nota Fiscal do item intermediário
           If lRet
              If Empty(M->EYU_DTNF) .And. M->EYU_MOEDA <> M->EEC_MOEDA
                 MsgInfo(STR0084,STR0051) // "Moeda do Item diferente da Moeda da capa do processo. A digitação da data da nota fiscal é obrigatória!"###"Alerta"
                 lRet := .F.
              EndIf
           EndIf
           // Validação para o Valor
           If lRet          
              nEE9Taxa := BuscaTaxa(M->EEC_MOEDA,M->EYU_DTNF,,.f.)        
              If M->EYU_MOEDA <> M->EEC_MOEDA
                 nValor := M->EYU_VALOR * nItTaxa
                 nValor := nValor / nEE9Taxa
              Else
                 nValor := M->EYU_VALOR
              EndIf  
              nValor := (aTotais[1]+nValor) // Volor total do fabricante para o item + valor Item atual
              If (M->EE9_PRECOI * M->EE9_SLDINI) < nValor 
                 MsgInfo(STR0071,STR0051) //"A somatória do campo 'Valor Prod.' de todos os produtos intermediários, não pode ser maior que o preço total do item no local de embarque." ### "Atenção"
                 lRet := .F.
              EndIf  
           EndIf

           // Validação para a quantidade de produto final informada na tela.
           If lRet 
              If M->EE9_SLDINI < AVTransUnid(M->EYU_UMPROD,M->EE9_UNIDAD,,M->EYU_QTDPRO)
                 MsgInfo(STR0072,STR0051) //"A quantidade de produto informada, não pode ser maior que a quantidade total do item." ### "Atenção"
                 lRet := .F.
              EndIf
           EndIf

           // Validação para a somatória das quantidades de produto final.
           If lRet
              nQtdTela := AVTransUnid(M->EYU_UMPROD,M->EE9_UNIDAD,,M->EYU_QTDPRO) 
              If M->EE9_SLDINI < (If(lQtdAdicionada,aTotais[2],aTotais[2]+nQtdTela))
                 MsgInfo(STR0073,STR0051) //"A somatória das quantidade de produto informadas, não podem ser maior que a quantidade total do item." ### "Atenção"
                 lRet := .F.
              EndIf
           EndIf
           
           //Validação para o Tipo Empresa Industrial
           If lRet
              nI := aScan(aTipoCnpj,{|x| x[1] == M->EYU_TIPO })
              If M->EYU_TIPO == "1"
                 If nI > 0  
                    MsgInfo(STR0074,STR0051) // "Não é permitido a Inclusão de mais de uma Empresa Industrial por item de Embarque!" ###"Atenção"
                    lRet := .F.
                 EndIf    
              EndIf
           EndIf 
           
           // Validação para o CNPJ da Empresa Industrial
           If lRet
              If M->EYU_TIPO == "1"   
                 nI := aScan(aTipoCnpj,{|x| x[1] == "2" .And. x[2] == Left(M->EYU_CNPJ,8)})
                 If nI > 0 .And. M->EYU_TIPO = "1"
                    MsgInfo(STR0075,STR0051) // "Não pode ser incluída uma Empresa-Industrial que possua os oitos primeiros digitos de CNPJ de Fabricante-Intermediário." ### "Atenção"
                    lRet := .F.
                 EndIf    
              EndIf 
           EndIf
           // Validação para o CNPJ do fabricante intermediario               
           If lRet
              If M->EYU_TIPO == "2"
                 nI := aScan(aTipoCnpj,{|x| x[1] == "1" .And. x[2] == Left(M->EYU_CNPJ,8)})
                 If nI > 0 .And. M->EYU_TIPO = "2"
                    MsgInfo(STR0076,STR0051) // "Não pode ser incluído um Fabricante-Intermediário que possua os oitos primeiros digitos de CNPJ de Empressa Industrial." ### "Atenção"
                    lRet := .F.
                 EndIf
              EndIf
           EndIf
           // Validação Preco X Quantidade contra EE9.
           If lRet 
              nEE9Taxa := BuscaTaxa(M->EEC_MOEDA,M->EYU_DTNF,,.f.)        
              If M->EYU_MOEDA <> M->EEC_MOEDA
                 nValor := M->EYU_VALOR * nItTaxa
                 nValor := nValor / nEE9Taxa
              Else
                 nValor := M->EYU_VALOR
              EndIf
              // nValor := nValor / M->EE9_PRECOI   Nopado por: AST - 18/09/08
              nValorMax := M->EYU_QTDPRO * M->EE9_PRECOI
              If nValor > nValorMax
                 MsgInfo(STR0082,STR0051) // "A relação quantidade e valor dititado, não pode ser maior que a quantidade digitada vezes o Preço unitário FOB do item de embarque."###"Atenção"
                 lRet := .F.
              EndIf
           EndIf
      
           //Validar o preenchimento dos campos: Ato Conecessorio e Sequencia do Ato.
           If lRet
              If (!Empty(M->EYU_ATOCON) .AND. Empty(M->EYU_SEQED3)) .OR. (!Empty(M->EYU_SEQED3) .AND. Empty(M->EYU_ATOCON))
                 MsgInfo(STR0099) //STR0099	"Verifique o preenchimento dos campos: Ato Concessorio e Sequencia do Ato"
                 lRet:= .F.
              Endif
           Endif
      
      Case nTipoItFab == EXC_DET .AND. MsgNoYes(STR0100,STR0050) // 'Confirma Exclusão ?' ### "Atenção" //STR0100	"Confirma a exclusão ?" //STR0050	Atenção
           
          If ChkFile("EWI")
              WKEWI->(DbSetOrder(1))
              If WKEWI->(DbSeek(WKEYU->EYU_PREEMB+WKEYU->EYU_SEQEMB+WKEYU->EYU_TIPO+WKEYU->EYU_CNPJ))
                 MsgInfo(STR0101)//STR0101	"Não é possível excluir um fabricante que possui notas fiscais vinculadas"
                 lRet:= .F.      
              Else   
                 WKEYU->(DbGoto(nRecnoIt))
                 If WKEYU->WK_RECNO # 0
                    Aadd(aEYUDel,WKEYU->WK_RECNO)
                 EndIf
                 WKEYU->(DbDelete())
                 WKEYU->(dbSkip(-1))
                 If WKEYU->(Bof())
                    WKEYU->(DbGoTop())
                 EndIf
              Endif
          Else
             WKEYU->(DbGoto(nRecnoIt))
             If WKEYU->WK_RECNO # 0
                Aadd(aEYUDel,WKEYU->WK_RECNO)
             EndIf
             WKEYU->(DbDelete())
             WKEYU->(dbSkip(-1))
             If WKEYU->(Bof())
                WKEYU->(DbGoTop())
             EndIf
          Endif
       
      Case cChamada == "EYU_TIPO"
           //Validação para o Tipo Empresa Industrial
           nI := aScan(aTipoCnpj,{|x| x[1] == M->EYU_TIPO })
           If M->EYU_TIPO == "1"
              If nI > 0  
                 MsgInfo(STR0074,STR0051) // "Não é permitido a Inclusão de mais de uma Empresa Industrial por item de Embarque!" ###"Atenção"
                 lRet := .F.
              EndIf
              M->EYU_MOEDA := "R$ "
           EndIf

         if M->EYU_TIPO <> WKEYU->EYU_TIPO .and. WKEWI->(DbSetOrder(1),DbSeek(WKEYU->EYU_PREEMB+WKEYU->EYU_SEQEMB+WKEYU->EYU_TIPO+WKEYU->EYU_CNPJ))
            MsgInfo( STR0115 ,STR0051) // "Não possível alterar o fabricante que já possui nota fiscal cadastrada! Delete as notas e tente novamente." ###"Atenção"
            lRet := .F.
            BREAK
         endif

      Case cChamada == "EYU_CNPJ" 
           // Validação para o CNPJ da Empresa Industrial
           If M->EYU_TIPO == "1"   
              nI := aScan(aTipoCnpj,{|x| x[1] == "2" .And. x[2] == Left(M->EYU_CNPJ,8)})
              If nI > 0 .And. M->EYU_TIPO = "1"                                         
                 MsgInfo(STR0075,STR0051) // "Não pode ser incluída uma Empresa-Industrial que possua os oitos primeiros digitos de CNPJ de Fabricante-Intermediário." ### "Atenção"
                 lRet := .F. 
              EndIf    
           EndIf 
           // Validação para o CNPJ do fabricante intermediario               
           If M->EYU_TIPO == "2"
              nI := aScan(aTipoCnpj,{|x| x[1] == "1" .And. x[2] == Left(M->EYU_CNPJ,8)})
              If nI > 0 .And. M->EYU_TIPO = "2"
                 MsgInfo(STR0076,STR0051) // "Não pode ser incluído um Fabricante-Intermediário que possua os oitos primeiros digitos de CNPJ de Empressa Industrial." ### "Atenção"
                 lRet := .F.
              EndIf
           EndIf

      Case cChamada == "EYU_VALOR"
           // Validação para o Valor
           nEE9Taxa := BuscaTaxa(M->EEC_MOEDA,M->EYU_DTNF,,.f.)
           If M->EYU_MOEDA <> M->EEC_MOEDA
              nValor := M->EYU_VALOR * nItTaxa
              nValor := nValor / nEE9Taxa
           Else
              nValor := M->EYU_VALOR
           EndIf  
           nValor := (aTotais[1]+nValor) // Volor total do fabricante para o item + valor Item atual
           If (M->EE9_PRECOI * M->EE9_SLDINI) < nValor 
              MsgInfo(STR0071,STR0051) //"A somatória do campo 'Valor Prod.' de todos os produtos intermediários, não pode ser maior que o preço total do item no local de embarque." ### "Atenção"
              lRet := .F.
           EndIf  
           
      Case cChamada == "EYU_QTDPRO" 
           // Validação para a quantidade de produto final informada na tela.
           If lRet 
              If M->EE9_SLDINI < AVTransUnid(M->EYU_UMPROD,M->EE9_UNIDAD,,M->EYU_QTDPRO)
                 MsgInfo(STR0072,STR0051) //"A quantidade de produto informada, não pode ser maior que a quantidade total do item." ### "Atenção"
                 lRet := .F.
              EndIf
           EndIf

           // Validação para a somatória das quantidades de produto final.
           If lRet
              nQtdTela := AVTransUnid(M->EYU_UMPROD,M->EE9_UNIDAD,,M->EYU_QTDPRO)
              If M->EE9_SLDINI < (If(lQtdAdicionada,aTotais[2],aTotais[2]+nQtdTela))
                 MsgInfo(STR0073,STR0051) //"A somatória das quantidade de produto informadas, não podem ser maior que a quantidade total do item." ### "Atenção"
                 lRet := .F.
              EndIf
           EndIf 
      
   EndCase     
   
End Sequence

Return lRet
/*
Função     : AE109WKEYU(lGrv,cAlias)
Objetivos  : Efetuar a atualização da tabela EYU com os dados da work WKEYU e
             atualizar os dados da tabela WKEYU com os dados da tabela EYU.
Parâmetros : 
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Function AE109WKEYU(lGrv,cAlias)

Local aOrd, nInc

If Type("aEYUDel") <> "A"
   aEYUDel := {}
EndIf

Begin Sequence
   If Select("WKEYU") == 0
      Break
   EndIf
   If !lGrv 
      AVReplace("EYU","WKEYU")
      WKEYU->WK_RECNO  := EYU->(RECNO())
      aOrd := SaveOrd({"EYU"})
   Else
      For nInc := 1 To Len(aEYUDel)
          EYU->(DbGoTo(aEYUDel[nInc]))
          MSMM(EYU->EYU_PR_DES,,,,EXCMEMO)
          EYU->(RecLock("EYU",.F.))
          EYU->(DbDelete())
          EYU->(MsUnlock())
      Next
         
      WKEYU->(DbGoTop())
      While WKEYU->(!Eof())
         If Empty(WKEYU->WK_RECNO)
            EYU->(RecLock("EYU",.T.))
         Else
            EYU->(DbGoTo(WKEYU->WK_RECNO))
            EYU->(RecLock("EYU",.F.))
         EndIf
         AvReplace("WKEYU","EYU")
         EYU->EYU_FILIAL := xFilial("EYU")
         EYU->EYU_PREEMB := M->EEC_PREEMB
         EYU->(MsUnlock())                
         MSMM(,TAMSX3("EYU_VM_DES")[1],,WKEYU->EYU_VM_DES,INCMEMO,,,"EYU","EYU_PR_DES")
         WKEYU->(DbSkip())
      EndDo
   EndIf
   
   If ValType(aOrd) == "A"
      RestOrd(aOrd, .T.)
   EndIf

End Sequence
   
Return Nil

/*
Função     : AE109TotFIt()
Objetivos  : Retornar totais dos produtos intermediários para o item de exportação selecionado.
Parâmetros : 
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Function AE109TotFIt()
Local nRet, nValor, aQtd:={}, aQtdAto:={}, aOrd := SaveOrd({"WKEYU"})
Local nI, nQtd,nQtdAto,aTipoCnpj := {}, nRegAtu, nItValor, nItTaxa
Begin Sequence
   nRegAtu := WKEYU->(Recno())
   WKEYU->(DbGoTop())
   aRet := {0,0,0}
   nValor := 0
   nQtdAto := 0
   Do While !WKEYU->(Eof())           
      If nRegAtu == WKEYU->(Recno())
         WKEYU->(DbSkip()) 
         Loop
      EndIf
      // Carrega CNPJ e TIPO
      Aadd(aTipoCnpj,{WKEYU->EYU_TIPO,Left(WKEYU->EYU_CNPJ,8)})
      // Calcula Totais do valor        
      If M->EEC_MOEDA <> WKEYU->EYU_MOEDA                      
         nEE9Taxa := BuscaTaxa(M->EEC_MOEDA,WKEYU->EYU_DTNF,,.f.)
         nItValor := WKEYU->EYU_VALOR * BuscaTaxa(WKEYU->EYU_MOEDA,WKEYU->EYU_DTNF,,.f.)
         nItValor := nItValor / nEE9Taxa
         nValor += nItValor 
      Else
         nValor += WKEYU->EYU_VALOR
      EndIf  
      // Carrega Quantidades por CNPJ e tipo.
      nI := aScan(aQtdAto,{|x| x[1] == WKEYU->EYU_CNPJ .And. x[2] == WKEYU->EYU_ATOCON})
      nQtdAto := AVTransUnid(WKEYU->EYU_UMPROD,M->EE9_UNIDAD,,WKEYU->EYU_QTDPRO) 
      If nI == 0         
         Aadd(aQtdAto,{WKEYU->EYU_CNPJ,WKEYU->EYU_ATOCON, nQtdAto})
      Else
         If(aQtdAto[nI,3] < nQtdAto,aQtdAto[nI,3] := nQtdAto,)
      EndIf 
      WKEYU->(DbSkip())
   EndDo     
   // Carrega Quantidades por CNPJ e tipo considerando os dados da tela.
   nI := aScan(aQtdAto,{|x| x[1] == M->EYU_CNPJ .And. x[2] == M->EYU_ATOCON})
   nQtdAto := AVTransUnid(M->EYU_UMPROD,M->EE9_UNIDAD,,M->EYU_QTDPRO) 
   lQtdAdicionada := .F.
   If nI > 0         
      If(aQtdAto[nI,3] < nQtdAto,aQtdAto[nI,3] := nQtdAto,)
      lQtdAdicionada := .T.
   EndIf 
   nQtdAto := 0        
   For nI := 1 To Len(aQtdAto)
       nQtdAto += aQtdAto[nI,3]
   Next
   aRet := {nValor,nQtdAto,aTipoCnpj}
End Sequence                  
WKEYU->(DbGoTo(nRegAtu))

Return aRet     

/*
Função     : ContaItFab()
Objetivos  : Retornar o total de registro com os dados do fabricante para o respectivo item de embarque.
Parâmetros : 
Retorno    : Numero de registros para o item de embarque.
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Static Function ContaItFab()

Local nContItFab := 0

WKEYU->(DbGoTop())
Do While ! EOF()
	If !WKEYU->DBDELETE
		nContItFab += 1
	Endif
	WKEYU->(DbSkip())		                
EndDo                
WKEYU->(DbGoTop())

Return nContItFab
/*
Função     : AE109F3PRD()
Objetivos  : Montar a consuta para o campo Código do produto.
Parâmetros : 
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Function AE109F3PRD()
Local lRet := .f.
Local Tb_Campos:={}, OldArea:=Select()
Local bSetF3 := SetKey(VK_F3)
Local nRec, cFiltra
Local cRE,cPROD,cITEM, cAtoCon,nQtdIt, nQtdDwb 
Local bF3Func := {||AE109F3PSQ()}
Private lInverte := .F., cMarca := GetMark()
Private cChavePesq := Space(20), lConsSb1 := .T.
Private oCbxTipoPsq, cTipoPsq, aTipoPsq := {STR0087,STR0078},  oDlgF3//STR0087	"Codigo" //STR0078	"Descrição" 
Private cPD
   Begin Sequence
      If Type("lIntDraw") == "U"
         lIntDraw := .F.
      EndIf
      If lIntDraw .And. !Empty(M->EYU_ATOCON)
         lConsSb1 := .F.        
         cAtocon := AvKey(M->EYU_ATOCON,"ED2_AC")
         ChkFile("EDC")
      EndIf
      //evitar recursividade
      Set Key VK_F3 To     
            
      If !lConsSb1
         bReturn:={||M->EYU_PROD:=ED2->ED2_ITEM,cPD := ED2->ED2_PD,cRE := ED2->ED2_RE ,cPROD := ED2->ED2_PROD,;
                     cITEM := ED2->ED2_ITEM,oDlgF3:End()}
         Aadd(Tb_Campos,{{||ED2->ED2_ITEM}  ,,STR0077}) // "Produto"
         Aadd(Tb_Campos,{{||Posicione("SB1",1,xFilial("SB1")+ED2->ED2_ITEM,"B1_DESC")},,STR0078}) // "Descrição" 
         
         DbSelectArea("ED2")      
         cFiltra := "'" +xFilial("ED2")+ "' == ED2->ED2_FILIAL .And." 
         cFiltra += "ED2->ED2_AC=='"+cAtoCon+"' .And. !Empty(ED2->ED2_MARCA)"
         Set Filter To &cFiltra
         ED2->(DbGoTop())
         cPD := ED2->ED2_PD
      Else
         bReturn:={||M->EYU_PROD:=SB1->B1_COD,oDlgF3:End()}
         Aadd(Tb_Campos,{{||SB1->B1_COD} ,,STR0077}) // "Produto"
         Aadd(Tb_Campos,{{||SB1->B1_DESC},,STR0078}) // "Descrição"
      EndIf

      nLarg := 800
      nAlt  := 600

      Define MsDialog oDlgF3 Title STR0079 From 0,0 To nAlt,nLarg pixel Of oMainWnd // "Produtos"

         nLin := 35
         nCol := 07
         @ nLin+1.7,nCol Say STR0080 Pixel of oDlgF3 // "Tipo"
         nCol := 40
         nLarg := 110
         nAlt  := 10

         @ nLin,nCol ComboBox oCbxTipoPsq Var cTipoPsq Items aTipoPsq Of oDlgF3 pixel Size nLarg,nAlt on change changebox()
         
         nLin := 50
         nCol := 07
         @ nLin+1.7,nCol Say STR0081 Pixel Of oDlgF3 // "Pesquisa"
         nCol := 40
         @ nLin,nCol MsGet cChavePesq   Size nLarg,nAlt Pixel Of oDlgF3
         
         nCol := 160
         Define SBUTTON From nLin,nCol Type 17 Action (Eval(bF3Func)) Enable Of oDlgF3 Pixel    //19

         nLin := 70
         nCol := 05
         nLarg := 400
         nAlt  := 295

         If !lConsSb1
            oMarkPrd:= MsSelect():New("ED2",,,TB_Campos,@lInverte,@cMarca,{nLin,nCol,nAlt,nLarg},,,oDlgF3)
            oMarkPrd:baval:= {|| lRet:=.t.,nRec:=ED2->(RecNo()), Eval(bReturn) }
         Else
            oMarkPrd:= MsSelect():New("SB1",,,TB_Campos,@lInverte,@cMarca,{nLin,nCol,nAlt,nLarg},,,oDlgF3)
            oMarkPrd:baval:= {|| lRet:=.t.,nRec:=SB1->(RecNo()), Eval(bReturn) }
         EndIf

         // Aadd( aButtons, {"ANALITIC", bF3Func , "Pesquisar..." } )

         // Define SBUTTON From 15,165 Type 1 Action (Eval(oMarkPrd:baval)) Enable Of oDlgF3 Pixel
         // Define SBUTTON From 25,165 Type 2 Action (oDlgF3:End()) Enable Of oDlgF3 Pixel
      Activate MsDialog oDlgF3 Centered On Init EnchoiceBar(oDlgF3, {|| Eval(oMarkPrd:baval),oDlgF3:End() } , {|| oDlgF3:End() } ,, )
      
      If !lConsSb1 .And. lRet
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+M->EYU_PROD))
         EDC->(DbSetOrder(1))
         //              Filial+Pedido+RE+Produto+Item 
         If EDC->(DbSeek(xFilial("EDC")+cPD+cRE+cPROD+cITEM))
            nQtdDwb := EDC->((EDC_QTDBAS * EDC_QTDEST) / EDC_QTDPRO)
            M->EYU_QTD := EDC->(nQtdDwb*(1 - EDC_PERDA/100)) * M->EE9_SLDINI //(EDC->EDC_FATNET/EDC->EDC_QTDPRO) + M->EE9_SLDINI
            M->EYU_QTD := AVTransUnid(SB1->B1_UM,M->EYU_NCM_UM,,M->EYU_QTD) 
         Else
            M->EYU_QTD := 0
         EndIf     
      ElseIf lConsSb1 .And. lRet  
         SB1->(DbSetOrder(1))
         SB1->(DbSeek(xFilial("SB1")+M->EYU_PROD))
      EndIf  
      
   End Sequence
   
   EE3->(DbClearFilter())    
   DbSelectArea(OldArea)
   If !lConsSb1   
      If !Empty(nRec)
         ED2->(dbGoTo(nRec))
      EndIf
   Else
      If !Empty(nRec)
         SB1->(dbGoTo(nRec))
      EndIf
   EndIf
   
   SetKey(VK_F3,bSetF3)
   
Return lRet
/*
Função     : changebox()
Objetivos  : atualiza o grid de produtos de acordo com o combobox.
Parâmetros : 
Retorno    : Nil
Autor      : Miguel Prado Gontijo
Data/Hora  : 08/10/2020
*/

static Function changebox()

   if cTipoPsq == aTipoPsq[1]
      SB1->(DbSetOrder(1))
   else
      SB1->(DbSetOrder(3))
   Endif

   oMarkPrd:oBrowse:Refresh()
   oDlgF3:Refresh() 

return
/*
Função     : AE109F3PSQ()
Objetivos  : Efetuar pesqueisa e posicionamento da função AE109F3PSQ().
Parâmetros : 
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
*/
Function AE109F3PSQ()

Begin Sequence

   if ! empty(cChavePesq)
      cChavePesq := alltrim(cChavePesq)
      If cTipoPsq == aTipoPsq[1]
         // cChavePesq := AvKey(cChavePesq,"B1_COD")
         SB1->(DbSetOrder(1))
      Else
         SB1->(DbSetOrder(3))
      EndIf
      SB1->(MsSeek(xFilial("SB1")+cChavePesq,.T.))
   EndIf

   If !lConsSb1
      If !SB1->(Eof())
         ED2->(DbSetOrder(1))
         ED2->(DbSeek(xFilial("ED2")+cPD+SB1->B1_COD))
         oDlgF3:Refresh()
      EndIf
   EndIf

   If SB1->(Eof())
      SB1->(dbgotop())
   EndIf
   
   oMarkPrd:oBrowse:Refresh()
   oDlgF3:Refresh()
   cChavePesq := IncSpace(cChavePesq, AvKey(cChavePesq,"B1_DESC"), .F.)

End Sequence

Return Nil

/*
Função     : AE109QBRIT() 
Objetivos  : Quebrar o item de embarque de acordo com os dados do fabricante, quando existir mais de um
             registro de fabricante com o mesmo Cnpj, não podem existir  Atos concessórios diferentes para 
             o mesmo RE.
Parâmetros : 
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Function AE109QBRIT() 
Local lRet := .T.,nRegAtu,cSeqEmbIt, cSeqOrgIt, cSeqNewIt, cProxSeq
Local aDadosQuebra :={},nI,nJ,nK,nL,nSldIni //lQuebraPri, lQuebraSec
Local aGrupoQuebra := {}, aRegProcessado := {}
Private aItFabr := {}, aDadosQebra := {}

Begin Sequence
   WKEYU->(DbSetFilter({|| EYU_PREEMB+EYU_SEQEMB == WORKIP->(EE9_PREEMB+EE9_SEQEMB) },"EYU_PREEMB+EYU_SEQEMB =='"+WORKIP->(EE9_PREEMB+EE9_SEQEMB)+"'"))
   WKEYU->(DbGoTop())
   Do While ! WKEYU->(Eof())                            
      // Grava os dados da WKEYU filtrados para registro corrente da Workip
      Aadd(aItFabr,{WKEYU->EYU_CNPJ,;    // 1 - CNPJ
                    WKEYU->EYU_ATOCON,;  // 2 - Ato Concessorio
                    WKEYU->EYU_SEQEMB,;  // 3 - Sequencia de Embarque
                    /*WKEYU->EYU_SEQORG*/,;  // 4 - Sequencia de Embarque Original
                    WKEYU->EYU_PROD,;    // 5 - Produto
                    WKEYU->EYU_TIPO,;    // 6 - Tipo
                    WKEYU->EYU_FABR,;    // 7 - Fabricante
                    WKEYU->EYU_FA_LOJ,;  // 8 - Loja Fabricante
                    WKEYU->EYU_FA_DES,;  // 9 - Descrição Fabricante
                    WKEYU->EYU_UF,;      // 10- UF
                    WKEYU->EYU_VM_DES,;  // 11- Descrição Produto
                    WKEYU->EYU_POSIPI,;  // 12- NCM
                    WKEYU->EYU_NCMDES,;  // 13- Descrição NCM
                    WKEYU->EYU_NCM_UM,;  // 14- Unidade Medida NCM
                    WKEYU->EYU_QTD,;     // 15- Quantidade
                    WKEYU->EYU_UMPROD,;  // 16- Unidade Medida Produto
                    WKEYU->EYU_QTDPRO,;  // 17- Quantidade Produto
                    WKEYU->EYU_MOEDA,;   // 18- Moeda
                    WKEYU->EYU_VALOR,;   // 19- Valor
                    WKEYU->EYU_DTNF,;    // 20- Data Nota Fiscal
                    WKEYU->(Recno())})   // 21- Recno
      WKEYU->(DbSkip())
   EndDo
   ASort(aItFabr,,, {|x, y| x[1]+x[2] < y[1]+y[2] })
   // Pega os primeiros Cnpj e Atos diferentes gravados na tabela fabricante para o item corrente. 
   For nI := 1 To Len(aItFabr)
          Aadd(aDadosQuebra,{aItFabr[nI,1], aItFabr[nI,2],aItFabr[nI,21]})
   Next
   
   // Atualiza saldo do registro corrente e efetua quebra de item.
   nRegAtu := WorkIp->(Recno())   
   For nI := 1 To Len(aItFabr)
       aGrupoQuebra := {}
       // Agrupa os registros/fabricantes itens intermediarios que efetuarão a quebra de registro da tabela EE9.
       // Efetua o controle dos registros que já foram processados. 
       For nJ := 1 To Len(aDadosQuebra)
           If Ascan(aRegProcessado,{|x| x[3] == aDadosQuebra[nJ,3]}) > 0
              Loop
           EndIf
           If aItFabr[nI,21] == aDadosQuebra[nJ,3]
              Loop
           EndIf
           If aItFabr[nI,1] == aDadosQuebra[nJ,1] .And. aItFabr[nI,2] == aDadosQuebra[nJ,2]
              Loop
           EndIf   
           If aItFabr[nI,1] == aDadosQuebra[nJ,1] .And. aItFabr[nI,2] <> aDadosQuebra[nJ,2]
              Aadd(aGrupoQuebra,{aDadosQuebra[nJ,1],aDadosQuebra[nJ,2],aDadosQuebra[nJ,3],nJ})
              Aadd(aRegProcessado,{aDadosQuebra[nJ,1],aDadosQuebra[nJ,2],aDadosQuebra[nJ,3]})
              If Ascan(aRegProcessado,{|x| x[1] == aDadosQuebra[nI,1] .And. x[2] == aDadosQuebra[nI,2] .And. x[3]==aDadosQuebra[nI,3]}) = 0 
                 Aadd(aRegProcessado,{aDadosQuebra[nI,1],aDadosQuebra[nI,2],aDadosQuebra[nI,3]})
              EndIf
           EndIf
       Next  
       ASort(aGrupoQuebra,,, {|x, y| x[1]+x[2] < y[1]+y[2] })      
       If Len(aGrupoQuebra) > 0
          cAtoAtu := Space(02) 
       EndIf
       // Efetua a atualização e quebra da tabela WorkIp/EE9
       For nJ := 1 To Len(aGrupoQuebra)
           If WorkIp->(Recno()) <> nRegAtu
              WorkIp->(DbGoTo(nRegAtu))
           EndIf
           nK := aGrupoQuebra[nJ,4] 
           nSldQuebra := AVTransUnid(aItFabr[nK,16],WorkIp->EE9_UNIDAD,M->EE9_COD_I,aItFabr[nK,17]) // 16- Unidade Medida Produto###// 17- Quantidade Produto
           SubTotal()
           nPercent := AjustaPeso(nSldQuebra,WorkIP->EE9_SLDINI,.T.) 
           WorkIP->(RecLock("WorkIP",.F.))
           nSldIni := WorkIP->EE9_SLDINI - nSldQuebra
           WorkIP->EE9_SLDINI := nSldIni
           WorkIP->EE9_PRCTOT := WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI
           WorkIP->EE9_PSLQTO := WorkIP->EE9_PSLQUN*WorkIP->EE9_SLDINI
           If WorkIP->EE9_SLDINI%WorkIP->EE9_QE == 0
              WorkIP->EE9_QTDEM1:= WorkIP->EE9_SLDINI/WorkIP->EE9_QE        //QUANT.DE EMBAL.
           Else
              WorkIP->EE9_QTDEM1:= Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE)+1 //QUANT.DE EMBAL.
           EndIf
   
           WorkIP->EE9_PSBRTO := WorkIP->EE9_PSBRTO*(1 - nPercent)
           WorkIP->WP_SLDATU  := If((WorkIP->WP_SLDATU-nSldQuebra)<= 0,0,WorkIP->WP_SLDATU-nSldQuebra)
           WorkIP->(msUnlock())
           SumTotal()
           AE100PrecoI()
           WorkIP->(msUnlock())
           // Quebra os registros para ato concessório diferentes para o mesmo CNPJ.
           If aItFabr[nK,2] <> cAtoAtu  
              cAtoAtu := aItFabr[nK,2] 
              Ae109QuebraItem(nSldQuebra,.T.)   
              WORKIP->(DbGoto(nRegFabrIt))
              WKEYU->(DbGoto(aItFabr[nK,21]))
              WKEYU->(RecLock("WKEYU",.F.))
              WKEYU->EYU_SEQEMB := WORKIP->EE9_SEQEMB
              WKEYU->(MsUnlock())
           Else // agrupa no novo registro criado, as quantidades dos demais registros que possuem o mesmo ato concessório e Cnpj.     
              WorkIp->(DbGoTo(nRegFabrIt))
              nSldQuebra := AVTransUnid(aItFabr[nK,16],WorkIp->EE9_UNIDAD,M->EE9_COD_I,aItFabr[nK,16]) // 16- Unidade Medida Produto###// 17- Quantidade Produto
              SubTotal()
              nPercent := AjustaPeso(nSldQuebra,WorkIP->EE9_SLDINI,.T.)//.F.) 
              WorkIP->(RecLock("WorkIP",.F.))
              nSldIni := WorkIP->EE9_SLDINI + nSldQuebra
              WorkIP->EE9_SLDINI := nSldIni
              WorkIP->EE9_PRCTOT := WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI
              WorkIP->EE9_PSLQTO := WorkIP->EE9_PSLQUN*WorkIP->EE9_SLDINI
              If WorkIP->EE9_SLDINI%WorkIP->EE9_QE == 0
                 WorkIP->EE9_QTDEM1:= WorkIP->EE9_SLDINI/WorkIP->EE9_QE        //QUANT.DE EMBAL.
              Else
                 WorkIP->EE9_QTDEM1:= Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE)+1 //QUANT.DE EMBAL.
              EndIf
              WorkIP->EE9_PSBRTO := WorkIP->EE9_PSBRTO*(1+nPercent)
              WorkIP->WP_SLDATU  := If((WorkIP->WP_SLDATU-nSldQuebra)<=0,0,WorkIP->WP_SLDATU-nSldQuebra)
              WorkIP->(msUnlock())
              SumTotal()
              AE100PrecoI()
              WorkIP->(msUnlock()) 
              WKEYU->(DbGoto(aItFabr[nK,21]))
              WKEYU->(RecLock("WKEYU",.F.))
              WKEYU->EYU_SEQEMB := WORKIP->EE9_SEQEMB
              WKEYU->(MsUnlock())
           EndIf
       Next
   Next
   WKEYU->(DbClearFilter())
End Sequence

Return lRet                        
/*
Função     : AE109QuebraItem() 
Objetivos  : Gerar um novo registro da tabela WorkIP
Parâmetros : 
Retorno    : Nil
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
                             
Function AE109QuebraItem(nQtdApropriada,lBotao)
*-----------------------------------------------*
Local nOldRec:=WorkIP->(RecNo())
Local nOldOrd:=WorkIP->(IndexOrd())
Local nOldArea := Select(), i:=0
Local cSeq

dbSelectArea("WorkIP")
If lBotao
   FOR i := 1 TO FCount()
      M->&(FIELDNAME(i)) := FieldGet(i)
   NEXT i
EndIf

//** Gravar SeqEmb sequencial.
WorkIP->( dbSetOrder(2) )
WorkIP->( dbGoBottom() )
M->EE9_SEQEMB := Str(Val(WorkIP->EE9_SEQEMB) + 1,AVSX3("EE9_SEQEMB",3))
//**

WorkIP->(RecLock("WorkIP",.T.))
FOR i := 1 TO FCount()
   WorkIP->&(FIELDNAME(i)) := M->&(FIELDNAME(i))
NEXT i
WorkIP->EE9_SLDINI := nQtdApropriada
WorkIP->EE9_PRCTOT := WorkIP->EE9_PRECO*WorkIP->EE9_SLDINI
WorkIP->EE9_PSLQTO := WorkIP->EE9_PSLQUN*WorkIP->EE9_SLDINI
WorkIP->EE9_PSBRTO := (WorkIP->EE9_PSBRTO/(1-nPercent))*nPercent  
If(!lItFabric,WorkIP->EE9_ATOCON := "",) 
If(!lItFabric,WorkIP->EE9_SEQED3 := "",) 
If(!lItFabric,WorkIP->EE9_QT_AC  := 0,)  
If(!lItFabric,WorkIP->EE9_VL_AC  := 0,)  
If(lItFabric,nRegFabrIt := WorkIP->(Recno()),)  
// Quebrar item sempre utilizando a work.
IF !EMPTY(WorkIP->EE9_QE)
   IF WorkIP->EE9_SLDINI%WorkIP->EE9_QE == 0 //(M->EE9_SLDINI%M->EE9_QE)==0
      WorkIP->EE9_QTDEM1:= WorkIP->EE9_SLDINI/WorkIP->EE9_QE        //QUANT.DE EMBAL.
   Else
      WorkIP->EE9_QTDEM1:= Int(WorkIP->EE9_SLDINI/WorkIP->EE9_QE)+1 //QUANT.DE EMBAL.
   EndIf
EndIf
//**

WorkIP->WP_FLAG := cMarca
WorkIP->WP_RECNO := 0
WorkIP->(msUnlock())
SumTotal()
AE100PrecoI()

WorkIP->(dbSetOrder(nOldOrd))
WorkIP->(dbGoTo(nOldRec))
dbSelectArea(nOldArea)

Return .T.

/*
Função     : AE109VLDif(cMoedaConv) 
Objetivos  : Calcula de acordo com o tipo(1=Empresa Industrial e 2=Fabricates-Intermediários) os valores
             na moeda informada, referentes aos itens intermediarios vinculados ao item de embarque, 
             a serem abatidos do valor total do item de embarque.
Parâmetros : cMoedaConv = Moeda a ser convertida.
Retorno    : Valor calculado
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/                             
Function AE109VLDif(cMoedaConv)
Local nRet := 0
Local cMoeDolar := EasyGParam("MV_SIMB2",,"US$")
Local nUSDTaxa, nItValor, nValor_Tp1, nValor_Tp2
Begin Sequence                             
   If Empty(cMoedaConv)
      cMoeDolar := EasyGParam("MV_SIMB2",,"US$") 
   Else
      cMoeDolar := cMoedaConv
   EndIf
   WKEYU->(DbSetFilter({|| EYU_PREEMB+EYU_SEQEMB == WORKIP->(EE9_PREEMB+EE9_SEQEMB) },"EYU_PREEMB+EYU_SEQEMB =='"+WORKIP->(EE9_PREEMB+EE9_SEQEMB)+"'"))
   WKEYU->(DbGoTop()) 
   nValor_Tp1 := 0
   nValor_Tp2 := 0
   Do While !WKEYU->(Eof())           
      // Calcula Totais do valor 
      nItValor := ConvVal(WKEYU->EYU_MOEDA,WKEYU->EYU_VALOR,If(!Empty(WKEYU->EYU_DTNF),WKEYU->EYU_DTNF,dDataBase)) 
      //If cMoeDolar <> WKEYU->EYU_MOEDA                      
      //   nUSDTaxa := BuscaTaxa(cMoeDolar,WKEYU->EYU_DTNF,,.f.)
      //   nItValor := WKEYU->EYU_VALOR * BuscaTaxa(WKEYU->EYU_MOEDA,WKEYU->EYU_DTNF,,.f.)
      //   nItValor := nItValor / nEE9Taxa
      If(WKEYU->EYU_TIPO == "1",nValor_Tp1 += nItValor,nValor_Tp2 += nItValor)             
      //Else
      //   If(WKEYU->EYU_TIPO == "1",nValor_Tp1 += WKEYU->EYU_VALOR,nValor_Tp2 += WKEYU->EYU_VALOR)             
      //EndIf  
      WKEYU->(DbSkip())
   EndDo     
   nRet := If(nValor_Tp1 > 0,nValor_Tp1 ,nValor_Tp2)
End Sequence
WKEYU->(DbClearFilter())

Return nRet

/*
Função     : AE109SalED3()
Objetivos  : Atualizar saldos do Ato Concessório para os itens intermediários vinclados ao item de Embarque.
Parâmetros : 
Retorno    : Valor calculado
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/                             

Function AE109SalED3()
*--------------------------------*
Local nOldOrd:=ED3->(IndexOrd())
Local cPD, nSaldo, nSaldoNCM, nValorAto
Local aAtosProc := {}
Begin Sequence
   ED3->(DbSetOrder(8))                                   
   ED0->(DbSetOrder(2))
   WKEYU->(DbSetFilter({|| EYU_PREEMB+EYU_SEQEMB == WORKIP->(EE9_PREEMB+EE9_SEQEMB) },"EYU_PREEMB+EYU_SEQEMB =='"+WORKIP->(EE9_PREEMB+EE9_SEQEMB)+"'"))
   WKEYU->(DbGoTop()) 
   //nValor_Tp1 := 0
   //nValor_Tp2 := 0
   Do While !WKEYU->(Eof())           
      //nItValor := ConvVal(WKEYU->EYU_MOEDA,WKEYU->EYU_VALOR,If(!Empty(WKEYU->EYU_DTNF),WKEYU->EYU_DTNF,dDataBase)) 
      If Ascan(aAtosProc,WKEYU->EYU_ATOCON) > 0
         WKEYU->(DbSkip())
         Loop
      EndIf
      If ED0->(DbSeek(xFilial("ED0")+WKEYU->EYU_ATOCON))
         cPD := ED0->ED0_PD
         ED3->(DbSeek(xFilial("ED3")+cPD+WorkIp->EE9_COD_I))
         Do While !ED3->(Eof()) .And. ED3->(ED3_FILIAL+ED3_PD+ED3_PROD) == xFilial("ED3")+cPD+WorkIp->EE9_COD_I
            If ED3->ED3_NCM <> WKEYU->EYU_POSIPI // ED3->ED3_AC <> WKEYU->EYU_ATOCON .Or.
               ED3->(DbSkip())
               Loop
            EndIf
            If !Empty(WorkIP->EE9_ATOCON)
               //If !Inclui .and. (WorkIP->EE9_ATOCON <> EE9->EE9_ATOCON .or. WorkIP->EE9_SEQED3 <> EE9->EE9_SEQED3)
               //   AE109VolED3("P")
               //EndIf
               //If ED3->(dbSeek(cFilED3+WKEYU->EYU_ATOCON+WorkIP->EE9_SEQED3)) 
               //   ED3->(dbSeek(cFilED3+WorkIP->EE9_ATOCON+WorkIP->EE9_SEQED3))
               If !ED3->( IsLocked() )  
                  ED3->(RECLOCK("ED3",.F.))
               EndIf              
               //AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,EE9->EE9_COD_I,EE9->EE9_QT_AC)
               // 
               If ! Empty(WKEYU->WK_RECNO)
                  EYU->(DbGoTo(WKEYU->WK_RECNO))
                  //nSaldo := AVTransUnid(EYU->EYU_UMPROD,ED3->ED3_UMPROD,,EYU->EYU_QTDPRO)
                  //nSaldoNCM := AVTransUnid(EYU->EYU_UMPROD,ED3->ED3_UMNCM,,EYU->EYU_QTDPRO) 
                  nSaldo := AVTransUnid(EE9->EE9_UNIDAD,ED3->ED3_UMPROD,,EE9->EE9_SLDINI)
                  nSaldoNCM := AVTransUnid(EE9->EE9_UNIDAD,ED3->ED3_UMNCM,,EE9->EE9_SLDINI)
                  nValorAto := ConvVal(EYU->EYU_MOEDA,EYU->EYU_VALOR,If(!Empty(EYU->EYU_DTNF),EYU->EYU_DTNF,dDataBase)) 
                  If !Inclui .and. EYU->EYU_ATOCON==ED3->ED3_AC .and. EYU->EYU_SEQED3==ED3->ED3_SEQSIS
                     ED3->ED3_SALDO  += nSaldo //EE9->EE9_QT_AC
                     ED3->ED3_SALNCM += nSaldoNCM //AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,EE9->EE9_COD_I,EE9->EE9_QT_AC)
                     If(EEC->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=nValorAto,ED3->ED3_SAL_SE+=nValorAto)
                  EndIf 
               EndIf
               //nSaldo := AVTransUnid(WKEYU->EYU_UMPROD,ED3->ED3_UMPROD,,WKEYU->EYU_QTDPRO)
               //nSaldoNCM := AVTransUnid(WKEYU->EYU_UMPROD,ED3->ED3_UMNCM,,WKEYU->EYU_QTDPRO) 
               nSaldo := AVTransUnid(WORKIP->EE9_UNIDAD,ED3->ED3_UMPROD,,WORKIP->EE9_SLDINI)
               nSaldoNCM := AVTransUnid(WORKIP->EE9_UNIDAD,ED3->ED3_UMNCM,,WORKIP->EE9_SLDINI) 
               nValorAto := ConvVal(WKEYU->EYU_MOEDA,WKEYU->EYU_VALOR,If(!Empty(WKEYU->EYU_DTNF),WKEYU->EYU_DTNF,dDataBase)) 
               ED3->ED3_SALDO  -= nSaldo //WorkIP->EE9_QT_AC
               ED3->ED3_SALNCM -= nSaldoNCM //AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,WorkIP->EE9_COD_I,WorkIP->EE9_QT_AC)
               If(M->EEC_COBCAM=="1",ED3->ED3_SAL_CO-=nValorAto,ED3->ED3_SAL_SE-=nValorAto)
               ED3->(msUnlock()) 
               If !Empty(WKEYU->WK_RECNO)
                  EYU->(DbGoTo(WKEYU->WK_RECNO))
                  EYU->(RECLOCK("EYU",.F.))                           
                  EYU->EYU_SEQED3 := ED3->ED3_SEQSIS
                  EYU->(MsUnlock())
               Else
                  EYU->(DbSeek(xFilial("EYU")+WKEYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON)))
                  EYU->(RECLOCK("EYU",.F.))                           
                  EYU->EYU_SEQED3 := ED3->ED3_SEQSIS
                  EYU->(MsUnlock())
               EndIf   
               Aadd(aAtosProc,WKEYU->EYU_ATOCON)
            ElseIf !Empty(EE9->EE9_ATOCON)
               AE109VolED3("P")  
            ElseIf Empty(EE9->EE9_ATOCON) .And. lEYUEstorno
               AE109VolED3("P")  
            EndIf
            ED3->(DbSkip())
         EndDo
      EndIf
      WKEYU->(DbSkip())
   EndDo
End Sequence

ED3->(dbSetOrder(nOldOrd))

Return.T.
/*
Função     : AE109VolED3(cTipo)
Objetivos  : Voltar os saldos da tabela de controle de Saldo ED3.
Parâmetros : 
Retorno    : 
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Function AE109VolED3(cTipo)
Local aOrd := SaveOrd({"ED3"})

Begin Sequence 
   ED3->(DbSetOrder(2)) 
   If cTipo=="E" .and. EEC->EEC_STATUS==ST_PC 
      Break
      //Return .T.
   ElseIf ED3->(dbSeek(cFilED3+WKEYU->(EYU_ATOCON+EYU_SEQED3)))
      If !ED3->( IsLocked() )  // Verifica se está travado.
         ED3->(RECLOCK("ED3",.F.))
      EndIf      
      If ! Empty(WKEYU->WK_RECNO)
         EYU->(DbGoTo(WKEYU->WK_RECNO))     
         nSaldo := AVTransUnid(EYU->EYU_UMPROD,ED3->ED3_UMPROD,,EYU->EYU_QTDPRO)
         nSaldoNCM := AVTransUnid(EYU->EYU_UMPROD,ED3->ED3_UMNCM,,EYU->EYU_QTDPRO) 
         nValorAto := ConvVal(EYU->EYU_MOEDA,EYU->EYU_VALOR,If(!Empty(EYU->EYU_DTNF),EYU->EYU_DTNF,dDataBase)) 
         ED3->ED3_SALDO  += nSaldo //EE9->EE9_QT_AC
         ED3->ED3_SALNCM += nSaldoNCM //AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,EE9->EE9_COD_I,EE9->EE9_QT_AC)
         If(EEC->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=nValorAto,ED3->ED3_SAL_SE+=nValorAto)
         ED3->(msUnlock())            
         If !Empty(WKEYU->WK_RECNO)
            EYU->(DbGoTo(WKEYU->WK_RECNO))
            EYU->(RECLOCK("EYU",.F.))                           
            EYU->EYU_SEQED3 := ""
            EYU->(MsUnlock())
         Else
            EYU->(DbSeek(xFilial("EYU")+WKEYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ+EYU_POSIPI+EYU_ATOCON)))
            EYU->(RECLOCK("EYU",.F.))                           
            EYU->EYU_SEQED3 := ""
            EYU->(MsUnlock())
         EndIf   
         //Aadd(aAtosProc,WKEYU->EYU_ATOCON)
      EndIf
   EndIf
End Sequence

RestOrd(aOrd)

Return .T.

/*
Função     : AE109VlEmb()
Objetivos  : Voltar os saldos da tabela de controle de Saldo ED3.
Parâmetros : 
Retorno    : 
Autor      : Julio de Paula Paz
Data/Hora  : 14/11/2007 - 14:00
Revisão    : 
*/
Function AE109VlEmb()
Local lRet := .T.

Begin Sequence
   WKEYU->(DbGoTop())
   Do While !WKEYU->(Eof())
      WorkIp->(DbSetFilter({|| EE9_PREEMB+EE9_SEQEMB == WKEYU->(EYU_PREEMB+EYU_SEQEMB) },"EE9_PREEMB+EE9_SEQEMB =='"+WKEYU->(EYU_PREEMB+EYU_SEQEMB)+"'"))
      WorkIp->(DbGoTop()) 
      If !WorkIp->(Eof())
         MsgInfo(STR0083,STR0051) // "Para excluir itens de embarque que possuem itens intermediários/Fabricantes, primeiro deve-se excluir os itens intermediários/Fabricantes!"###"Alerta" 
         lRet := .F.
         Break
      EndIf
      
      WKEYU->(DbSkip())
   EndDo
End Sequence
WorkIP->(DbSetFilter({|| WP_FLAG == cMarca },"WP_FLAG =='"+cMarca+"'"))
WorkIP->(DbGoTop())
Return lRet


/*
Função     : AE109GrvCusto()
Objetivos  : Gravar o custo realizado do Embarque rateado por Item.
Parâmetros : Nenhum
Retorno    : lRet
Autor      : Eduardo C. Romanini
Data/Hora  : 27/02/2008 - 11:00
Revisão    : 
*/
*----------------------*
Function Ae109GrvCusto()
*----------------------*
Local lRet           := .T.
Local lFobDescontado := EasyGParam("MV_AVG0086",,.f.)
                 
Local cRateio   := EasyGParam("MV_AVG0021",,"3")
Local cTipoCom  := ""

Local nRateio   := 0
Local nComissao := 0
Local nInc      := 0
Local nPos      := 0 

/*AOM - 31/03/2010 - Incluido o 4º parametro para não ser apresentada a mensagem de
 Valor de Conversão zerado na Cotação de Moedas na gravação do Embarque*/
Local nTaxa     := BuscaTaxa(M->EEC_MOEDA,dDataBase,,.F.)  

Local aDespesas := {}
Local aDespNac  := {}
Local aComissao := {}
Local aOrd      := SaveOrd({"EE9"})      

Begin Sequence
   
   //Apaga todos os registros anteriores do embarque.
   EYW->(DbSetOrder(1))
   If EYW->(DbSeek(xFilial("EYW")+M->EEC_PREEMB))
      While EYW->(!EOF()) .and. EYW->(EYW_FILIAL + EYW_PREEMB) == xFilial("EYW")+M->EEC_PREEMB
         
         EYW->(RecLock("EYW",.F.))
         EYW->(DbDelete())
         EYW->(MsUnlock())
      
         EYW->(DbSkip())
      EndDo
   EndIf   
   
   //Despesas Nacionais
   EET->(DbSetOrder(1))
   If EET->(DbSeek(xFilial("EET")+M->EEC_PREEMB+OC_EM))
      While EET->(!EOF()) .and. EET->(EET_FILIAL + EET_PEDIDO + EET_OCORRE) == xFilial("EET")+M->EEC_PREEMB+OC_EM
         
         nPos := aScan(aDespNac,{|a| a[1] == EET->EET_DESPES})
         If nPos == 0
            aAdd(aDespNac,{EET->EET_DESPES,EET->EET_VALORR})
         Else
            aDespNac[nPos][2] += EET->EET_VALORR
         EndIf

         EET->(DbSkip())
      EndDo   
   EndIf   
   
   EE9->(DbSetOrder(3))
   If EE9->(DbSeek(xFilial("EE9")+M->EEC_PREEMB))
      While EE9->(!EOF()) .and. EE9->(EE9_FILIAL + EE9_PREEMB) == xFilial("EE9")+M->EEC_PREEMB
          
         //Define o tipo de Rateio que será realizado nos itens.
         If cRateio == "1" //Peso Liquido
            nRateio := EE9->EE9_PSLQTO / EEC->EEC_PESLIQ
                            
         ElseIf cRateio == "2" //Peso Bruto
            nRateio := EE9->EE9_PSBRTO / EEC->EEC_PESBRU
        
         Else //Preço Fob
            nRateio   := EE9->EE9_PRCINC / EEC->EEC_TOTPED
         
         EndIf
         
         //Frete
         If !Empty(EE9->EE9_VLFRET)
            SYB->(DbSetOrder(1))
            If SYB->(DbSeek(xFilial("SYB")+"102"))

               nValor := EE9->EE9_VLFRET
               nValor := nValor * nTaxa
                              
               aAdd(aDespesas,{EE9->EE9_SEQEMB,SYB->YB_DESP,AllTrim(SYB->YB_DESCR),nValor})
            EndIf   
         EndIf

         //Seguro
         If !Empty(EE9->EE9_VLSEGU)
            SYB->(DbSetOrder(1))
            If SYB->(DbSeek(xFilial("SYB")+"103"))

               nValor := EE9->EE9_VLSEGU
               nValor := nValor * nTaxa
                              
               aAdd(aDespesas,{EE9->EE9_SEQEMB,SYB->YB_DESP,AllTrim(SYB->YB_DESCR),nValor})
            EndIf   
         EndIf

         //Despesas Nacionais
         For nInc := 1 to Len(aDespNac)

            SYB->(DbSetOrder(1))
            If SYB->(DbSeek(xFilial("SYB")+aDespNac[nInc][1]))
            
               nValor := aDespNac[nInc][2] * nRateio
                                            
               aAdd(aDespesas,{EE9->EE9_SEQEMB,SYB->YB_DESP,AllTrim(SYB->YB_DESCR),nValor})
            EndIf
         Next
         
         //Comissão
         If !Empty(EE9->EE9_CODAGE)
         
            EEB->(DbSetOrder(1))
            If EEB->(DbSeek(xFilial("EEB")+EE9->EE9_PREEMB+OC_EM+EE9->EE9_CODAGE))
               
               Do Case
                  Case EEB->EEB_TIPCOM == "1"
                       cTipoCom := STR0102 //"120-A Remeter"//STR0102	"120-A Remeter"
                  Case EEB->EEB_TIPCOM == "2"
                       cTipoCom := STR0103 //"121-Conta Gráfica" //STR0103	"121-Conta Gráfica"
                  Case EEB->EEB_TIPCOM == "3"
                       cTipoCom := STR0104 //"122--Conta Gráfica" //STR0104	"122-Conta Gráfica"
               End Case
               
               If EEB->EEB_TIPCVL $ "13" // Percentual/Percentual por item.
                
                  If lFobDescontado
                     nComissao := Round((EE9->EE9_PRCINC - EE9->EE9_VLDESC)*(EE9->EE9_PERCOM/100),4)

                  Else   
                     nComissao := Round(EE9->EE9_PRCINC*(EE9->EE9_PERCOM/100),4)
 
                  EndIf
               
               Else // Valor Fixo
                  nComissao := Round(WorkAg->EEB_VALCOM,4)
 
               EndIf     
               
               nComissao := nComissao * nTaxa
               
               aAdd(aDespesas,{EE9->EE9_SEQEMB,Left(cTipoCom,3),SubStr(cTipoCom,5,Len(cTipoCom)),nComissao})
               
            EndIf
         
         EndIf

         EE9->(DbSkip())
      EndDo
   EndIf
   
   //Realiza a gravação da tabela.
   For nInc := 1 To Len(aDespesas)
      
      EYW->(RecLock("EYW",.T.))
      
      EYW->EYW_FILIAL := xFilial("EYW")
      EYW->EYW_PREEMB := EEC->EEC_PREEMB

      EYW->EYW_SEQEMB := aDespesas[nInc][1]
      EYW->EYW_DESPES := aDespesas[nInc][2]
      EYW->EYW_DESCR  := Alltrim(Upper(aDespesas[nInc][3]))
      EYW->EYW_VALOR  := Round(aDespesas[nInc][4],4)
      
      EYW->EYW_MOEDA  := M->EEC_MOEDA
      EYW->EYW_TAXA   := nTaxa
      EYW->EYW_DTTAXA := dDataBase

      EYW->(MsUnlock())
   Next

End Sequence

RestOrd(aOrd)

Return lRet

/*
Função     : AE109NfFabr()
Objetivos  : Manutencão para Vinculacao de Notas Fiscais de Fabricantes.
Parâmetros : Nenhum
Retorno    : lRet
Autor      : Thiago Rinaldi Pinto
Data/Hora  : 29/10/2010 - 11:00
Revisão    : 
*/
Static Function AE109NfFabr()

Local lRet:=.T.,cOldArea:=Select(),nOpcNF:=0,oDlgNf3,oProcesso,oSeq,oFabr,oAtoCon
Local nL1:=3.5, nL2:=5, nC1:=1, nC2:=14, nC3:=05, nC4:=20
Local lInverte:= .F.
Local bOk := {|| nOpcNF := 1, oDlgNf3:End() }
Local bCancel := {|| oDlgNf3:End() }
Local cNFTitulo := STR0105 //STR0105	"Manutenção de Notas Fiscais"
Local cProcesso := ""
Local cSeqEmb   := ""
Local cFabr     := "" 
Local cAto      := ""   

Local cFileBackup := CriaTrab(,.f.), aDelBak
Local oMarkEWI
Local aCampoEWI:= {}

aCampoEWI:={{{||WKEWI->EWI_NF}   ,"",AVSX3("EWI_NF",AV_TITULO)},; 
                  {{||WKEWI->EWI_SERIE},"",AVSX3("EWI_SERIE",AV_TITULO)},;
                  {{||WKEWI->EWI_DTNF} ,"",AVSX3("EWI_DTNF",AV_TITULO)},;
                  {{||WKEWI->EWI_QTD}  ,"",AVSX3("EWI_QTD",AV_TITULO)},;
                  {{||WKEWI->EWI_VLNF} ,"",AVSX3("EWI_VLNF",AV_TITULO)}}    
      

cProcesso := WKEYU->EYU_PREEMB
cSeqEmb   := WKEYU->EYU_SEQEMB
cFabr     := WKEYU->EYU_FABR
cAto      := WKEYU->EYU_ATOCON

Begin Sequence
   
   If WKEYU->(EasyRecCount()) == 0
      MsgInfo(STR0106)//STR0106	"Não existem Fabricantes vinculados para inclusão de notas fiscais!"
      lRet:= .F.
      Break
   Endif 

   If Empty(WKEYU->EYU_ATOCON)
      MsgInfo(STR0107) //STR0107	"Fabricante não possui Ato Concessório vinculado!"
      lRet:= .F.
      Break
   Endif 
   
   DbSelectArea("WKEWI")
   WKEWI->(dbGoTop())
   TETempBackup(cFileBackup)
   aDelBak := aClone(aEWIDel)
   
   WKEWI->(DbSetFilter({|| EWI_PREEMB+EWI_SEQEMB+EWI_TIPO+EWI_CNPJ == WKEYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ) },"EWI_PREEMB+EWI_SEQEMB+EWI_TIPO+EWI_CNPJ =='"+WKEYU->(EYU_PREEMB+EYU_SEQEMB+EYU_TIPO+EYU_CNPJ)+"'"))
   
   WKEWI->(dbGoTop())
 
   nOpcNF := 0
 
   Define MsDialog oDlgNf3 Title cNFTitulo From 9,0 TO 28,110 Of oMainWnd   // 28,70
         
      @ nL1,nC1 Say STR0108 Of oDlgNf3  //	STR0108	"Processo"
      @ nL1,nC2 Say STR0109 Of oDlgNf3  //STR0109	"Seq. Emb"
      @ nL1,nC3 MsGet oProcesso Var cProcesso When .F. Size 50,7 RIGHT Of oDlgNf3
      @ nL1,nC4 MsGet oSeq      Var cSeqEmb   When .F. Size 50,7 RIGHT Of oDlgNf3

      @ nL2,nC1 Say STR0110 Of oDlgNf3 //STR0110	"Fabricante"
      @ nL2,nC2 Say STR0111 Of oDlgNf3 //STR0111	"Ato Concessorio" 
      @ nL2,nC3 MsGet oFabr       Var cFabr When .F. Size 50,7 RIGHT Of oDlgNf3
      @ nL2,nC4 MsGet oAtoCon     Var cAto   When .F. Size 50,7 RIGHT Of oDlgNf3
      
      
      oMarkEWI:= MsSelect():New("WKEWI",,,aCampoEWI,@lInverte,@cMarca,PosDlgDown(oDlgNf3),,, oDlgNf3)
      
      
   Activate MsDialog oDlgNf3 On Init ;                                                     
       AVBar(nSelecao,oDlgNf3,bOk,bCancel,ENCH_ADD,{|opc| AE109DETNF(opc,oMarkEWI)}) Centered

   
   WKEWI->(DbClearFilter())
   If nOpcNF == 0 //Cancelar
      DbSelectArea("WKEWI")
      AvZap()
      TERestBackup(cFileBackup)
      aEWIDel := aClone(aDelBak)
   EndIf
   
   E_EraseArq(cFileBackup)
   
End Sequence

dbselectarea(cOldArea)

Return lRet


/*
Função     : AE109DETNF()
Objetivos  : Permitir Manutencão de Notas Fiscais de Fabricantes.
Parâmetros : nTipoNf  - Define o tipo da operacão
             oMarkEWI - Objeto da MsSelect
Retorno    : lRet
Autor      : Thiago Rinaldi Pinto
Data/Hora  : 29/10/2010 - 11:00
Revisão    : 
*/
Static Function AE109DETNF(nTipoNF,oMarkEWI)


Local lRet:=.T.,cOldArea:=Select(),oDlgItNf,nOpcNF:=0
Local nRecOld := WKEYU->(RecNo())
Local cTitNfFab := STR0112 //	STR0112	"Notas Fiscais do Fabricante"
Local aItAltera := {}, nI:= 1
Local aEWIEnchoice := {}        
Local bIt_OK := {||nOpcNF:=1,oDlgItNf:End()}  
Local bIt_Cancel := {||nOpcNF:=0,oDlgItNf:End()}

Private oItMsmGet , aFabButtons := {}, nRecnoNf

Private aTela[0][0],aGets[0],aHeader[0]
 
Begin Sequence
   
   If nTipoNF <> INC_DET
      If WKEWI->(Eof() .And. Bof())
         Help(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
         Break
      EndIf
   EndIf
 
   aEWIEnchoice := {"EWI_NF","EWI_SERIE","EWI_DTNF","EWI_QTD","EWI_VLNF","EWI_CHVNFE"}
                    
   aNFAltera := aClone(aEWIEnchoice)
   
   IF nTipoNF==INC_DET
      WKEWI->(DbGoBottom())
      WKEWI->(DbSkip())
   EndIf
   
   nRecnoNf:=WKEWI->(Recno())  
   
   For nI := 1 To WKEWI->(FCount())
      M->&(WKEWI->(FieldName(nI))) := WKEWI->(FieldGet(nI))
   Next nInc
     
   M->EWI_PREEMB := M->EE9_PREEMB
   M->EWI_SEQEMB := M->EE9_SEQEMB
     
   M->EWI_TIPO   := WKEYU->EYU_TIPO
   M->EWI_CNPJ   := WKEYU->EYU_CNPJ
   M->EWI_POSIPI := WKEYU->EYU_POSIPI
   M->EWI_ATOCON := WKEYU->EYU_ATOCON
   M->EWI_SEQED3 := WKEYU->EYU_SEQED3
   M->EWI_FABR   := WKEYU->EYU_FABR
   
   Define MsDialog oDlgItNf Title cTitNfFab From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel
      aPos := PosDlg(oDlgItNf)
      oItMsmGet := MsMGet():New("EWI", , 3, , , , aEWIEnchoice,  aPos, aNFAltera, IF(STR(nTipoNF,1)$Str(VIS_DET,1)+"/"+Str(EXC_DET,1),3,2),,,,oDlgItNf)                                                                                                                                                  
             
      oItMsmGet:oBox:Align := CONTROL_ALIGN_ALLCLIENT
      oDlgItNf:lMaximized := .T.   
   Activate MsDialog oDlgItNf On Init EnchoiceBar(oDlgItNf,{|| If(AE109VlNF("TELA",nTipoNF),Eval(bIt_OK),)},bIt_Cancel)
   
   IF nOpcNF == 1 // ok
      IF nTipoNF == INC_DET
         WKEWI->(DbAppend())
      EndIf
      
      IF ! (Str(nTipoNF,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1))
         If nTipoNF <> INC_DET
            WKEWI->(DbGoTo(nRecOld))
         EndIf
         AVReplace("M","WKEWI")
      ENDIF
      
      oMarkEWI:oBrowse:Refresh()
      
   Else 
      If nTipoNF == INC_DET
         WKEWI->(DbGoTo(nRecOld))
      Endif
   EndIf

End Sequence

Dbselectarea(cOldArea)
   
Return lRet 

/*
Função     : AE109VlNF()
Objetivos  : Validacoes da Manutencão de Nota Fiscal de Fabricantes.
Parâmetros : cChamada - Origem da chamada da funcão
             nTipoNf  - Define o tipo da operacão
Retorno    : lRet
Autor      : Thiago Rinaldi Pinto
Data/Hora  : 29/10/2010 - 11:00
Revisão    : 
*/
Static Function AE109VlNF(cChamada,nTipoNf)

Local lRet:= .T.

 
If nTipoNf == EXC_DET .AND. MsgNoYes(STR0113) // 'Confirma Exclusão ?' ### "Atenção" //	STR0113	Confirma a exclusão?
   WKEWI->(DbGoto(nRecnoNf)) 
   If WKEWI->WK_RECNO # 0
      Aadd(aEWIDel,WKEWI->WK_RECNO)
   EndIf
   WKEWI->(DbDelete())
   WKEWI->(dbSkip(-1))
   If WKEWI->(Bof())
      WKEWI->(DbGoTop())
   EndIf
Endif

Return lRet

/*
Função     : AE109WKEWI(lGrv,cAlias)
Objetivos  : Efetuar a atualização da tabela EWI com os dados da work WKEWI e
             atualizar os dados da tabela WKEWI com os dados da tabela EWI.
Parâmetros : 
Retorno    : Nil
Autor      : Thiago Rinaldi Pinto
Data/Hora  : 29/10/2010 - 11:00
Revisão    : 
*/
Function AE109WKEWI(lGrv,cAlias)

Local nInc

If Type("aEWIDel") <> "A"
   aEWIDel := {}
EndIf

Begin Sequence
   If Select("WKEWI") == 0
      Break
   EndIf
   If !lGrv 
      AVReplace("EWI","WKEWI")
      WKEWI->WK_RECNO  := EWI->(RECNO())
   Else
      For nInc := 1 To Len(aEWIDel)
          EWI->(DbGoTo(aEWIDel[nInc]))
          EWI->(RecLock("EWI",.F.))
          EWI->(DbDelete())
          EWI->(MsUnlock())
      Next
         
      WKEWI->(DbGoTop())
      While WKEWI->(!Eof())
         If Empty(WKEWI->WK_RECNO)
            EWI->(RecLock("EWI",.T.))
         Else
            EWI->(DbGoTo(WKEWI->WK_RECNO))
            EWI->(RecLock("EWI",.F.))
         EndIf
         AvReplace("WKEWI","EWI")
         EWI->EWI_FILIAL := xFilial("EWI")
         EWI->EWI_PREEMB := M->EEC_PREEMB
         EWI->(MsUnlock())                
         WKEWI->(DbSkip())
      EndDo
   EndIf
   
End Sequence
   
Return Nil

/*
Função     : AE109WhenAto()
Objetivos  : Definir o When dos campos EYU_ATOCON e EYU_SEQED3
Parâmetros : cCampo - Campo no qual o When será validado.
Retorno    : lRet
Autor      : Thiago Rinaldi Pinto
Data/Hora  : 29/10/2010 - 11:00
Revisão    : 
*/
Function AE109WhenAto(cCampo)

Local lRet:= .T.

Do Case

Case cCampo == "EYU_ATOCON" .OR. cCampo == "EYU_SEQED3"
   If ChkFile("EWI")
      WKEWI->(DbSetOrder(1))
      If WKEWI->(DbSeek(WKEYU->EYU_PREEMB+WKEYU->EYU_SEQEMB+WKEYU->EYU_TIPO+WKEYU->EYU_CNPJ))
         lRet:= .F. 
      Endif
   Endif
End Case

Return lRet

/*
Função  : EECCriaTrab
Autor   : Rodrigo Mendes Diaz
Data    : 23/08/12
Objetivo: Cópia da E_CriaTrab com tratamentos específicos para reaproveitar arquivos de trabalho.
*/
Function EECCriaTrab(cAlias,aSemSX3,cAliasWork,aHeaderP,lDelete, aCposNewStru)
Return E_CriaTrab(cAlias,aSemSX3,cAliasWork,aHeaderP,lDelete,aCposNewStru)

/*
Função  : EECIndRegua
Autor   : Rodrigo Mendes Diaz
Data    : 23/08/12
Objetivo: Substitui a IndRegua com tratamentos específicos para reaproveitar arquivos de trabalho.
*/
Function EECIndRegua(cAlias,cNIndex,cExpress,xOrdem,cFor,cMens, nIndex)
Return IndRegua(cAlias,cNIndex,cExpress,xOrdem,cFor,cMens, nIndex)


/*
Função  : EECGetIndexFile
Autor   : Rodrigo Mendes Diaz
Data    : 23/08/12
Objetivo: Obtém o nome do arquivo de índice a ser utilizado/criado, com tratamentos específicos para reaproveitar arquivos de trabalho.
*/
Function EECGetIndexFile(cAlias, cNomArqAlias, nIndex)
Return cFileName := CriaTrab(, .F.)

/*
Função  : EECSetKeepUsrFiles
Autor   : Rodrigo Mendes Diaz
Data    : 23/08/12
Objetivo: Habilita tratamento para manter arquivos de trabalho por ponto de entrada.
*/
Function EECSetKeepUsrFiles()
	If EasyEntryPoint("EECKEEPFILES")
		__KeepUsrFiles := ExecBlock("EECKEEPFILES",.f.,.f.,"EECKEEPFILES")
	EndIf
Return Nil

/*
Função  : EECEraseArq
Autor   : Rodrigo Mendes Diaz
Data    : 23/08/12
Objetivo: Tratamento específico para manter/excluir arquivos de trabalho (Auxiliar à E_ERASEARQ()).
*/
FUNCTION EECEraseArq(cNomArq,cIndice2,cIndice3)
Return E_ERASEARQ(cNomArq,cIndice2,cIndice3)
