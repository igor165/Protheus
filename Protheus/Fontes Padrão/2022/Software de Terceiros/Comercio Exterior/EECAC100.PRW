#INCLUDE "EECAC100.ch"
/*
Programa        : EECAC100.PRW
Objetivo        : Manutencao de clientes SA1
Autor           : Cristiano A. Ferreira
Data/Hora       :
Obs.            :
*/
#include "EEC.CH"
#include "dbtree.ch"

#COMMAND E_RESET_AREA => SA1->(DBSETORDER(1))

#define BXG_DET     97//Baixa Gerencial - RMD - 08/11/07

/*
Funcao      : EECAC100()
Parametros  : nenhum
Retorno     : .T.
Objetivos   : executar mbrowse
Autor       : Heder M Oliveira
Data/Hora   : 09/12/98 10:25
Revisao     :
-LCS.18/10/2006.08:20 -> INCLUSAO DO PONTO DE ENTRADA ANTES DA EDICAO DOS DADOS.
 A VARIAVEL nOPC FOI PASSADA DE LOCAL PARA PRIVATE
 INCLUSAO DO PONTO DE ENTRADA NA EXCLUSAO DO CLIENTE
Obs.        : "Importadores/Clientes"
*/
Function EECAC100(xAutoCab,xAutoItens,nOpcAuto,xAdianAuto,cOpcComp)
    Local lRet:=.T.,cOldArea:=select(),cAlias:="SA1"
    Private cCadastro:=AVTITCAD("SA1"),cTipoCad:=CD_SA1
    // ** By JBJ - 04/11/2002 - Flag para acionamento de pagamento antecipado ...
    Private lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)
    Private aRotina  := MenuDef()
    Private nOpcEWR  := 0     // Operação para Botao OK

	//FSM - 08/12/11 - ExecAuto  *** Processamento via rotina automática (MsExecAuto).
	Private lExecAuto := xAutoCab <> NIL
	Private aAutoCab
	Private aAutoEE3   := xAutoItens
    Private aEEQAuto   := xAdianAuto
    Private lEEQAuto   := aEEQAuto <> Nil
    Private nOpcEEQ    := nOpcAuto
    Private cFiltro := Nil //RMD - 13/03/17 - Permite incluir um filtro via ponto de entrada
    If Type("lMsErroAuto") <> "L"
        lMsErroAuto := .F.
    EndIf

    IF(EasyEntryPoint("EECAC100"),ExecBlock("EECAC100",.F.,.F.,"ANTES_BROWSE"),)   // GFP - 07/08/2012 - Inclusão de Ponto de Entrada

    Begin sequence

        (cAlias)->(DBSETORDER(1))
        //FSM - 08/12/11 - ExecAuto
		If !lExecAuto
		    //DFS - 21/07/12 - Para conter os parametros de configurações financeiros na rotina de cambio de exportacão
            If IsIntEnable("001")
               SetKey (VK_F12,{|a,b| AcessaPerg("FIN040",.T.)})
            EndIf
			// *** Processamento via Interface.
			//mBrowse( 6, 1,22,75,cAlias) //RMD - 13/03/17 - Permite informar um filtro para o mBrowse
            mBrowse(6,1,22,75,cAlias,,,,,,,,,,,,,,cFiltro)
			// ***
		Else
			// *** Processamento via rotina automática (MsExecAuto).
			aAutoCab   := xAutoCab
            If ValType(cOpcComp) == "C"
                //Busca a rotina complementar no aRotina (Menudef) e identifica a posição no array
                If (nOpcAuto := aScan(aRotina, {|x| Upper(x[2]) == Upper(cOpcComp) })) > 0
                    AvKeyAuto(aAutoCab)
                    If EasySeekAuto(cAlias, aAutoCab, 1)//A função MBrowseAuto não posiciona automaticamente o registro quando a opção é diferente de 4 ou 5
                        //Executa a rotina complementar via MBrowseAuto
                        MBrowseAuto(nOpcAuto, aAutoCab, cAlias,, .T.)
                    Else
                        EasyHelp(STR0093, STR0040) //"O cliente informado não foi localizado"###"Aviso"
                    EndIf
                Else
                    EasyHelp(StrTran(STR0094, "XXX", cOpcComp), STR0040) //"A rotina complementar informada ('XXX') não foi localizada."###"Aviso"
                EndIf
            Else
			    MBrowseAuto(nOpcAuto, aAutoCab, cAlias,, .T.)
            EndIf
	        // ***
		EndIf
    End sequence

    dbselectarea(cOldArea)
Return lRet

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 17/01/07 - 15:42
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina :=  { { STR0001,   "AxPesqui"  , 0 , PESQUISAR},; //"Pesquisar"
                    { STR0002,   "AC100MAN"  , 0 , VISUALIZAR},; //"Visualizar"
                    { STR0003,   "AC100MAN"  , 0 , INCLUIR},; //"Incluir"
                    { STR0004,   "AC100MAN"  , 0 , ALTERAR},; //"Alterar"
                    { STR0005,   "AC100MAN"  , 0 , EXCLUIR,3} } //"Excluir"

If EasyGParam("MV_AVG0039",,.f.)
   aAdd(aRotina,{STR0024,"AC100ADIAN",0,6}) //"Adiantamentos"
EndIf

//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAC100MNU")
	aRotAdic := ExecBlock("EAC100MNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
/*
Funcao      : AC100MAN()
Parametros  :
Retorno     :
Objetivos   :
Autor       : Heder M Oliveira
Data/Hora   :
Revisao     :
Obs.        :
*/
Function AC100MAN(cAlias,nReg,nOpc)
    Local cOldArea:=select(),nOLDORDER:=INDEXORD()/*,oDlg*/,nInc//,bVal_OK
    Local lGravaOK:=.T., bCancel//, nOpcA := 3
    Local lEditDoc := (nOpc == INCLUIR .Or. nOpc == ALTERAR),cArq2,cInd2Arq2
    LOCAL aSEMEXH, j:=0
    /*Local aCpo := {}*/ //RMD - 13/03/17 - Movido para private
	Local bProc
	Local i
    Private aCpo := {}
    Private aTela[0][0],aGets[0],nUsado:=0
    Private aCampos,aHeader[0],lEXH
    Private cNomArq,aBUTTONS := {}
    Private lInverte := .F.
    Private cMarca := GetMark()
    Private bVal_OK, nOpcA := 3 , oDlg
    Private cCliCod:="",; // cCliCod:=CriaVar("A1_COD"),;
            cCliNome:=CriaVar("A1_NOME"),cLojaCli
    Private cCliCodPais:=CriaVar("A1_PAIS"),cCliDscPais:=CriaVar("YA_NOIDIOM")
    Private nOrdem := 1
    PRIVATE cARQEXH,aDELEXH

    Private nOpcRdm:= nOpc  // TRP - 27/03/2012

    Private cNomeArqEWR := Space(0)
    Private lRet:=.T. //LRS - 13/09/2016
     bCancel := {||nOpcA:=0, If(!lExecAuto, oDlg:End(),)} //FSM - 08/12/11 - ExecAuto

    // ** By JBJ - 29/08/2003 - Na versão 811, opção sempre disponível.
    lEXH := .t. //lEXH    := IF(SELECT("EXH")<>0,.T.,.F.)

    aDELEXH := {}
    Begin Sequence

       aAdd(aButtons,{"BMPCPO",{||AC100ComplCli(nOpc)},STR0074/*,STR0075*/}) // "Informações Complementares" $$$ "Inf Compl" - ACSJ - 30/03/2004

       If nOpc <> INCLUIR .And. !Empty(SA1->A1_NIF)
          AtualizaNIF()
       EndIf

       IF nOpc==INCLUIR

          bVal_OK:={||nOpcA:=1,IF(Obrigatorio(aGets,aTela) .AND. AC100VldOk(nOpc) .And. AC100Crit("A1_COMAGE"), If(!lExecAuto, oDlg:End(),),nOpcA:=0)} //FSM - 08/12/11 - ExecAuto //FSM - 05/10/2012

          For nInc := 1 TO (cAlias)->(FCount())
             M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
          Next nInc

          cCliCod := M->A1_COD
          // ** Cria as variaveis de memória para o arquivo de complemento do sa1.
          For j := 1 TO EXJ->(FCount())
             M->&(EXJ->(FieldName(j))) := CriaVar(EXJ->(FieldName(j)))
          Next

          // Carrega dados para a chave dos outros modulos ...
          M->A1_LOJA := IF(EMPTY(M->A1_LOJA),AvKey(".","A1_LOJA"),M->A1_LOJA)
       Else

          For nInc := 1 TO (cAlias)->(FCount())
             M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
          Next nInc

          //AMS - 10/03/2004 às 14:28.
          M->A1_VM_MARC := MSMM(SA1->A1_CODMARC,  20,,,LERMEMO)
          M->A1_VM_OBS  := MSMM(SA1->A1_OBS,      60,,,LERMEMO)

          IF EasyEntryPoint("EECAC100")
             ExecBlock("EECAC100",.F.,.F.,"POSCARGA_CAMPOS_CAPA")
          Endif

          EXJ->(DbSetOrder(1))
          If EXJ->(DbSeek(xFilial("EXJ")+M->A1_COD+M->A1_LOJA)) // Se encontrar carrega do arquivo.
             For j := 1 TO EXJ->(FCount())
                M->&(EXJ->(FieldName(j))) := EXJ->(FieldGet(j))
             Next
          Else // Cria a var. memória caso não exista a moeda cadastrada.
             For j := 1 TO EXJ->(FCount())
                M->&(EXJ->(FieldName(j))) := CriaVar(EXJ->(FieldName(j)))
             Next
          EndIf

          If nOpc = VISUALIZAR
             bVal_OK:={|| If(!lExecAuto, oDlg:End(),)} //FSM - 08/12/11 - ExecAuto
          ElseIf nOpc==ALTERAR
             bVal_OK:={||nOpca:=2,IF(Obrigatorio(aGets,aTela) .And. AC100VldOk(nOpc) .AND. AC100Crit("A1_COMAGE"), If(!lExecAuto, oDlg:End(),), nOpcA:=0)} //FSM - 08/12/11 - ExecAuto  //FSM - 05/10/2012
          ElseIf nOpc = EXCLUIR
                 IF ! INTEGREF("SA1")
                    BREAK
                 ENDIF
                 bVal_OK:={||If(AC100VldOk(nOpc), (nOpca:=0,AC100MANE(nOpc), If(!lExecAuto, oDlg:End(),)),)} //FSM - 08/12/11 - ExecAuto   //FSM - 05/10/2012
          EndIf

          IF nOpc <> VISUALIZAR
              // SA1->(RecLock("SA1"))  //By JPP - 18/04/2005 - 13:50
              If ! SA1->(Reclock("SA1"))  //By JPP - 18/04/2005 - 13:50 - Bloquear o registro durante a alteração, exclusão e inclusão.
                 Break
              EndIf
           Endif
       Endif

       // *** GFP - 09/11/2010 - Botão "Bancos Cobradores"
       If nModulo == 29 .AND. EasyGParam("MV_INTITAU",,.F.)
          aADD(aButtons,{"DESTINOS",{|| If(Empty(M->A1_COD).And.Empty(M->A1_LOJA),MsgInfo("Informe o código e a loja do importador.","Atenção"),AC100Banco())},"Bancos Cobradores"})
          aCampos := Array(EWR->(FCount()))
          aSemSX3 := { {"EWR_COD"  ,"C" ,6 ,0 },;
                       {"EWR_LOJA" ,"C" ,2 ,0 } }

          //FDR - 09/09/2011
          If Select("WorkEWR") > 0
             WorkEWR->(DbCloseArea())
          EndIf
          FillGetDB(4, "EWR", "WorkEWR",,1, xFilial("EWR")+M->(A1_COD+A1_LOJA), {|| EWR->(EWR_FILIAL+EWR_COD+EWR_LOJA) },,,,,,,,,,,)
          Private aWkHist := {}
       EndIf
       // *** Fim

       IF lEditDoc
          If nModulo == 29
             aAdd(aButtons,{"NOTE" /*"EDITABLE"*/,{||AC100CSel()},STR0106/*,STR0076*/}) //"Documentos/Atividades do Cliente" $$$ "Doctos" - ACSJ - 30/03/2004
          EndIf
          // *** Cria Work para selecao de documentos/atividades ...
          aCampos:= Array(EE1->(fCount()))
          aSemSX3:= {{"WKMARCA","C",2,0},{"WK_DESDOC","C",AVSX3("EEA_TITULO",AV_TAMANHO),0}}
          //TRP - 25/01/07 - Campos do WalkThru
          AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
          AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
          cArq2  := E_CriaTrab("EE1",aSemSX3,"Work2")
          IndRegua("Work2",cArq2+TEOrdBagExt(),"WK_DESDOC",,,STR0009) //"Processando Arquivo Temporário..."
          cInd2Arq2 := CriaTrab(,.f.)
          IndRegua("Work2",cInd2Arq2+TEOrdBagExt(),"EE1_ORDEM",,,STR0009) //"Processando Arquivo Temporário..."
          Set Index To (cInd2Arq2+TEOrdBagExt()),(cArq2+TEOrdBagExt())
       Endif
       // Se existir o arquivo Clientes X Produtos inclui o botao
       DbSelectArea("SA1")     //LRL 03/02/2004
       IF lEXH

          If nModulo == 29
             AADD(aBUTTONS,{"CLIENTE" /*"NOVACELULA"*/,{|| AC100CLPR(nOPC)},STR0054/*,STR0077*/}) //"Cliente X Produtos" $$$ "Cli X Prod" - ACSJ - 30/03/2004
          EndIf
          aSEMEXH := {{"TEXH_RECNO","N",08,0},;
                      {"TEXH_DESCR","C",40,0}}
          //TRP - 25/01/07 - Campos do WalkThru
          AADD(aSEMEXH,{"TRB_ALI_WT","C",03,0})
          AADD(aSEMEXH,{"TRB_REC_WT","N",10,0})

          aCAMPOS := ARRAY(EXH->(FCOUNT()))
          cARQEXH := E_CRIATRAB("EXH",aSEMEXH,"TEXH")
          INDREGUA("TEXH",cARQEXH+TEOrdBagExt(),"EXH_COD_I",,,STR0009) //"Processando Arquivo Temporário..."
          SET INDEX TO (cARQEXH+TEOrdBagExt())
          EXH->(DBSETORDER(1))
          EXH->(DBSEEK(XFILIAL("EXH")+AVKEY(M->A1_COD,"EXH_CODCLI")+AVKEY(M->A1_LOJA,"EXH_CLLOJA")))
          DO WHILE ! EXH->(EOF()) .AND.;
             EXH->(EXH_FILIAL+EXH_CODCLI+EXH_CLLOJA) == (XFILIAL("SA1")+AVKEY(M->A1_COD,"EXH_CODCLI")+AVKEY(M->A1_LOJA,"EXH_CLLOJA"))

             TEXH->(DBAPPEND())
             AVREPLACE("EXH","TEXH")
             TEXH->TEXH_RECNO := EXH->(RECNO())
             TEXH->TEXH_DESCR := MSMM(EXH->EXH_DESC,AVSX3("EXH_VM_DESC",AV_TAMANHO),1)
             TEXH->EXH_VM_DES := MSMM(EXH->EXH_DESC,AVSX3("EXH_VM_DESC",AV_TAMANHO))
             TEXH->TRB_ALI_WT := "EXH"
             TEXH->TRB_REC_WT := EXH->(Recno())
             EXH->(DBSKIP())
          ENDDO
       ENDIF

       // Work dos Contatos ...
	   bProc := {|| EE3Manut(nOpc,cTipoCad,AC_WK,{M->A1_COD,M->A1_LOJA}) }
	   If !lExecAuto
          Processa(bProc)
	   Else
	      Eval(bProc)
	   EndIf

       //RMD - 13/03/17
       aCpo := AvCposEnc("SA1", Nil, "A1_COMIS")

       If nOpc == ALTERAR .And. empty(M->A1_NIF) .And. !Empty(M->EXJ_NIF)
          M->A1_NIF := M->EXJ_NIF
       EndIf

       // LCS.18/10/2006.08:20 - inclusao do ponto de entrada
       IF EasyEntryPoint("EECAC100")
          ExecBlock("EECAC100",.F.,.F.,{"ANTES_DO_MSGET",nOPC})
       Endif

       While ( nOpca>=3 )
           nOpcA:=0
           aTela := {}
           aGets := {}

           // 22.mai.2009 - 719381 - O campo A1_COMIS não é utilizado nos módulos Average - HFD
           //RMD - 13/03/17 - Movido para antes do ponto de entrada
           //aCpo := AvCposEnc("SA1", Nil, "A1_COMIS")

           //FSM - 08/12/11 - ExecAuto
           If !lExecAuto

	           DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL


	              If nModulo == 29  // MsSelect Contatos ...
	                 oEnch1 := MsMGet():New( cAlias, nReg, nOpc,,,,aCpo ,PosDlgUp(oDlg))
	                 EE3Manut(nOpc,cTipoCad,AC_MS,{oDlg,M->A1_COD})
	                 oEnch1:oBox:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	              Else
	                 oEnch1 := MsMGet():New( cAlias, nReg, nOpc,,,,aCpo ,PosDlgUp(oDlg))
	                 oEnch1:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	              EndIf

	           ACTIVATE MSDIALOG oDlg ON INIT If(nModulo == 29,(EE3Manut(nOpc,cTipoCad,AC_IN,{oDlg,bVal_OK,bCancel,M->A1_COD,aButtons}), oEnch1:oBox:Align := CONTROL_ALIGN_TOP),(EnchoiceBar(oDlg,bVal_OK,bCancel,,aButtons)))

           Else
                For i := 1 To 10  // GFP - 21/02/2014
                   If lRet := EnchAuto(cAlias, aAutoCab, {|| Obrigatorio(aGets, aTela)}, nOpc, aCpo)
                      Exit
                   EndIf
                Next

				If lRet
				   If Len(aAutoEE3) > 0
			          aEval(aAutoEE3, {|x| If(!lMsErroAuto, EE3Manut(nOpc,cTipoCad,"EXECAUTO", {M->A1_COD,M->A1_LOJA,x}), ) })
			       EndIf
				   Eval(bVal_Ok)
				Else
				   Eval(bCancel)
				EndIf
           EndIf

           IF (EasyEntryPoint("EECAC100"),Execblock("EECAC100",.F.,.F.,"ANTES_SALVAR"),)
           IF lRet
           Do Case
              Case nOpca==1
                   Begin Transaction
				      bProc := {||lGravaOk:=AC100Grava(.T.,nOpc)}
				      If !lExecAuto
					     Processa(bProc)
				      Else
					     Eval(bProc)
				      EndIf
                      If !lGravaOk
                         Help(" ",1,"A110NAORE")
                      Else
                         //Processa Gatilhos
                         EvalTrigger()
                         If __lSX8
                            ConfirmSX8()
                         Endif
                      EndIf
                   End Transaction
              Case nOpca==2
                   SYF->(dbgoto(nReg))  //soh p/confirmar
                   bProc := {||lGravaOk:=AC100Grava(.F.,nOpc)}
				   If !lExecAuto
					  Processa(bProc)
				   Else
					  Eval(bProc)
				   EndIf
           otherwise
              IF nOpcA == 0 // Cancel
                 SA1->(MSUnlock())
                 IF nOpc == INCLUIR
                    While __lSX8
                        RollBackSX8()
                    Enddo
                 Endif
              Else
                 // if nOpcA != 0
                 nOpcA := 3 // para voltar no loop
              endif
           End
	       EndIF

        Enddo

        // Fecha e Apaga Work de Contatos ...
        EE3Manut(nOpc,cTipoCad,AC_ER)

        E_RESET_AREA
    End Sequence

    If lEditDoc .And. Select("WORK2") <> 0  // By JPP - 18/04/2005 -14:00 - Inclusão da instrução Select.
       Work2->(E_EraseArq(cArq2,cInd2Arq2))
    EndIf
    IF lEXH .AND. SELECT("TEXH") <> 0
       TEXH->(E_ERASEARQ(cARQEXH))
    ENDIF
    dbselectarea(cOldArea)
    dbsetorder(nOLDORDER)

    If Select("WorkEWR") > 0
       WorkEWR->(avzap())
       WorkEWR->(DbCloseArea())
       E_EraseArq(cNomeArqEWR)
    EndIf

    Return lRet
*--------------------------------------------------------------------
/*
Funcao      : AC100MANE()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Excluir Registros
Autor       : Heder M Oliveira
Data/Hora   : 07/12/98 14:16
Revisao     :
Obs.        :
*/
Static Function AC100MANE(nOpc)
   Local lRet:=.T.,cOldArea:=select(), aOrd:=SaveOrd({"EXJ"})
   Begin sequence
      if lExecAuto .Or. MsgYesNo(STR0006,STR0007) //"Confirma Exclusão?"###"Atenção" //FSM - 08/12/11 - ExecAuto
         Reclock("SA1",.F.)

         // Work dos Contatos ...
		 bProc := {|| EE3Manut(nOpc,cTipoCad,AC_DE,{M->A1_COD,M->A1_LOJA}) }
  	     If !lExecAuto
            Processa(bProc)
	     Else
	        Eval(bProc)
	     EndIf

         // EXCLUI OS PRODUTOS ASSOCIADOS
         IF lEXH
            EXH->(DBSETORDER(1))
            EXH->(DBSEEK(XFILIAL("EXH")+AVKEY(SA1->A1_COD,"A1_COD")))
            DO WHILE ! EXH->(EOF()) .AND.;
               EXH->(EXH_FILIAL+EXH_CODCLI) = (XFILIAL("EXH")+AVKEY(SA1->A1_COD,"A1_COD"))
               *
               EXH->(RECLOCK("EXH",.F.))
               MSMM(EXH->EXH_DESC,,,,EXCMEMO)
               EXH->(DBDELETE())
               EXH->(MSUNLOCK())
               EXH->(DBSKIP())
            ENDDO
         ENDIF

         EXJ->(DbSetOrder(1))
         If EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))
            EXJ->(RecLock("EXJ",.f.))
            EXJ->(DbDelete())
            EXJ->(MsUnLock())
         EndIf

         MSMM(SA1->A1_CODMARC,,,,EXCMEMO)
         MSMM(SA1->A1_OBS,,,,EXCMEMO)
         // LCS.18/10/2006.08:20 - inclusao do ponto de entrada
         IF EasyEntryPoint("EECAC100")
            ExecBlock("EECAC100",.F.,.F.,"AC100MANE")
         Endif
         SA1->(DBDELETE())
         SA1->(MsUnlock())
      Endif
   End Sequence
   Dbselectarea(cOldArea)
   RestOrd(aOrd)
Return lRet

/*
Funcao      : AC100ComplCli(nOpc).
Parametros  : nOpc - Opção (Inclusão/Alteração/Exclusão/Visualização).
Retorno     : .t.
Objetivos   : Gravar informações complementares do cliente.
Autor       : Jefeson Barros Jr.
Data/Hora   : 27/01/04 09:23.
Revisao     :
Obs.        :
*/
*---------------------------------*
Static Function AC100ComplCli(nOpc)
*---------------------------------*
Local lRet:=.f., oDlg, aButtons:={}
Local aOldaTela:=aTela, aOldaGets:=aGets, j:=0, aCpoEnc
Local bOk := {|| If(Obrigatorio(aGets,aTela),(oDlg:End(),lRet:=.t.),nil)}
      bCancel := {||oDlg:End()}

Begin Sequence

   aTela := {}
   aGets := {}

   If !EECFlags("INTTRA")
      aCpoEnc := AvCposEnc("EXJ", Nil, "EXJ_INTTRA")//Nunca exibe o campo "EE5_CODINT", se a integração com Inttra estiver desligada.
   EndIf

   /*
   If nModulo == 85 .AND. EasyGParam("MV_ESS0027",,9) >= 10 .AND. FindFunction("RS400VldNIF")
      bOk := {|| If(Obrigatorio(aGets,aTela) .AND. RS400VldNIF("EXJ"),(oDlg:End(),lRet:=.t.),nil)}
   Else
      bOk := {|| If(Obrigatorio(aGets,aTela),(oDlg:End(),lRet:=.t.),nil)}
   EndIf
   */
   bOk := {|| If(Obrigatorio(aGets,aTela) .AND. RS400VldNIF("EXJ"),(oDlg:End(),lRet:=.t.),nil)}//Executa sempre a validação do NIF para que o campo A1_NIF receba a mesma informação

   M->EXJ_NIF := M->A1_NIF

   Define MsDialog oDlg Title STR0074 From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel //"Informações Complementares"
      oEnCh1 := MsMGet():New("EXJ",,nOpc,,,, aCpoEnc, PosDlg(oDlg))
	  oEnCh1:oBox:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   Activate MsDialog oDlg On Init (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

End Sequence

aTela := aOldaTela
aGets := aOldaGets

Return lRet

/*
Funcao      : AC100Grava(lGrava)
Parametros  : lGrava:= .T. - append blank
                       .F. - replace
Retorno     : .T.
Objetivos   : Gravar Header e mensagens
Autor       : Heder M Oliveira
Data/Hora   : 20/11/98 09:38
Revisao     :
Obs.        :
*/
Static Function AC100Grava(lGrava,nOpc)
    Local lRet:=.T.,cOldArea:=select(), i:=0, j:=0
    Local lEditDoc := (nOpc == INCLUIR .Or. nOpc == ALTERAR)

    Begin sequence

        E_Grava("SA1",lGrava)
        RECLOCK("SA1",.F.)

        /*For j := 1 TO EXJ->(FCount())
           // ** Verifica se existe algum campo preenchido para o EXJ e realiza a gravação.
           If !Empty(&("M->"+EXJ->(FieldName(j))))*/
              M->EXJ_COD  := M->A1_COD
              M->EXJ_LOJA := M->A1_LOJA

              If !lGrava
                 EXJ->(DbSetOrder(1))
                 If EXJ->(DbSeek(xFilial("EXJ")+M->A1_COD+M->A1_LOJA))
                    EXJ->(RecLock("EXJ",.f.))
                 Else
                    EXJ->(RecLock("EXJ",.t.))
                 EndIf
              Else
                 EXJ->(DbSetOrder(1))
                 EXJ->(RecLock("EXJ",!EXJ->(DbSeek(xFilial("EXJ")+M->A1_COD+M->A1_LOJA))))
              EndIf

              AvReplace("M","EXJ")
              EXJ->EXJ_NIF := SA1->A1_NIF
              EXJ->(MsUnLock())

              /*If EXJ->(FieldPos("EXJ_NIF")) # 0
                 SA1->A1_NIF := EXJ->EXJ_NIF
              EndIf
              */
              
        /*   EndIf
        Next*/

        If ! lGrava
           //excluir antes
           MSMM(M->A1_CODMARC,,,,EXCMEMO)
           MSMM(M->A1_OBS,,,,EXCMEMO)
        ENDIF

        //If !lExecAuto  // GFP - 24/02/2014
		//AAF 22/07/2015 - Execauto tem que gravar também, se não o campo fica em branco e perde o conteudo...
           MSMM(,AVSX3("A1_VM_MARC",AV_TAMANHO),,M->A1_VM_MARC,INCMEMO,,,"SA1","A1_CODMARC")
           MSMM(,AVSX3("A1_VM_OBS",AV_TAMANHO),,M->A1_VM_OBS,INCMEMO,,,"SA1","A1_OBS")
        //EndIf

        SA1->(MsUnlock())

        // Work dos Contatos ...
        EE3Manut(nOpc,cTipoCad,AC_GR,{M->A1_COD,M->A1_LOJA})

        IF lEditDoc
           // Gravar o EE1 no OK (final)
           AC100GrvEE1()
        Endif
        IF lEXH
           // EXCLUI OS REGISTRO DO VETOR
           FOR I := 1 TO LEN(aDELEXH)
               EXH->(DBGOTO(aDELEXH[I]))
               EXH->(RECLOCK("EXH",.F.))
               // EXCLUI O TEXTO
               MSMM(EXH->EXH_DESC,,,,EXCMEMO)
               // EXCLUI O ITEM
               EXH->(DBDELETE())
           NEXT
           // GRAVA OS ITENS
           TEXH->(DBGOTOP())
           DO WHILE ! TEXH->(EOF())
              IF EMPTY(TEXH->TEXH_RECNO)
                 EXH->(RECLOCK("EXH",.T.))
              ELSE
                 EXH->(DBGOTO(TEXH->TEXH_RECNO))
                 EXH->(RECLOCK("EXH",.F.))
                 // EXCLUI O TEXTO
                 MSMM(EXH->EXH_DESC,,,,EXCMEMO)
              ENDIF
              // GRAVA OS DADOS
              EXH->EXH_FILIAL := XFILIAL("EXH")
              EXH->EXH_CODCLI := SA1->A1_COD
              EXH->EXH_CLLOJA := SA1->A1_LOJA
              AVREPLACE("TEXH","EXH")
              MSMM(,AVSX3("EXH_VM_DES",AV_TAMANHO),,TEXH->EXH_VM_DES,INCMEMO,,,"EXH","EXH_DESC")
              TEXH->(DBSKIP())
           ENDDO
        ENDIF

        // *** GFP 11/11/2010 - Gravação de dados na Tabela EWR
        If nOpcEWR == 1
           WorkEWR->(DbGoTop())
           Do While WorkEWR->(!Eof())
              EWR->(DbGoTo(WorkEWR->EWR_REC_WT))
              If WorkEWR->EWR_FLAG == .T.
                 If EWR->(RecLock("EWR", .F.))
                    EWR->(DbDelete())
                 EndIf
              Else
                 If EWR->(RecLock("EWR", (WorkEWR->EWR_REC_WT == 0)))
                    EWR->EWR_COD  := M->A1_COD
                    EWR->EWR_LOJA := M->A1_LOJA
                    AvReplace("WorkEWR","EWR")
                 EndIf
              EndIf
              EWR->(MsUnLock())
              WorkEWR->(DbSkip())
           EndDo
        EndIf

        IF EasyEntryPoint("EECAC100")
           ExecBlock("EECAC100",.F.,.F.,"POS_GRAVA")  // GFP - 07/04/2014
        Endif

    End Sequence

    dbselectarea(cOldArea)
Return lRet

/*
Funcao      : AC100ConfSel
Parametros  : cAlias := Alias do arquivo
              nReg   := Numero do registro
              nOpc   := 2 - Visualizar
                        3 - Incluir
                        4 - Alterar
                        5 - Excluir
Retorno     : Nil
Objetivos   : Conferencia da Selecao de Documentos/Atividades
Autor       : Cristiano A. Ferreira
Data/Hora   : 05/08/2002 15:30
Revisao     :
Obs.        :
*/
STATIC Function AC100CSel(cAlias,nReg,nOpc)

Local oDlg
Local nLinSel	:= 15
Local aCpos := { ColBrw("EE1_ORDEM","Work2"),;
               {{|| Work2->EE1_DOCUM},"",STR0010},; //"Código"
               {{|| Work2->EE1_FASE+"-"+If(Work2->EE1_FASE="1",STR0011,If(Work2->EE1_FASE="2",STR0012,; //"Todas"###"Processo"
                    If(Work2->EE1_FASE="3",STR0013,If(Work2->EE1_FASE="4",STR0014,""))))},"",STR0015},; //"Embarque"###"Financas"###"Fase"
               {{|| Work2->EE1_TIPDOC},"",STR0016},; //"Tipo"
               {{|| Work2->WK_DESDOC},"",STR0017}}  //"Documentos"

Local i, bOk, bCancel, nOpcao := 0
Local xValue, aPos
Local aButtons:={}
Local oMsSelect
LOCAL oPanel

Begin Sequence

   aAdd(aButtons,{"NOTE" /*"EDITABLE"*/,{||nOpcao:=2,/*oDlg:End(),*/AC100Sel()},STR0008/*,STR0076*/}) //"Relação de Documentos/Atividades" $$$ "Doctos" -  ACSJ - 30/03/2004
   aAdd(aButtons,{/*"VCUP"*/"PMSSETAUP",{||MoveUp(oMsSelect,"Work2")},STR0025/*,STR0078*/})  //"Move para Cima"         $$$ "Sobe"   -  ACSJ - 30/03/2004
   aAdd(aButtons,{/*"VCDOWN"*/"PMSSETADOWN",{||MoveDown(oMsSelect,"Work2")},STR0026/*,STR0079*/}) //"Move para Baixo"    $$$ "Desce"  -  ACSJ - 30/03/2004

   // ** Set das variaveis
   cCliCod     := M->A1_COD
   cLojaCli    := M->A1_LOJA
   cCliNome    := M->A1_NOME
   cCliCodPais := M->A1_PAIS
   cCliDscPais := Posicione("SYA",1,xFilial("SYA")+M->A1_PAIS,"YA_NOIDIOM")

   IF ! AC100GrvW2() // Grava Work2
      Break
   Endif

   While .t.
      nOpcao := 0
      aTela := {}
      aGets := {}

      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

		 @00,00 MSPANEL oPanel PROMPT "" SIZE 30,45 OF oDlg // --- ACSJ - 30/03/2004
				 
         @ nLinSel,007 Say STR0020 Size 65,07 PIXEL OF oPanel //"Codigo"
         @ nLinSel,100 Say STR0021   Size 65,07 PIXEL OF oPanel //"Nome"

         @ nLinSel,35  MSGET cCliCod  Size 040,07  Pixel OF oPanel When .f.
         @ nLinSel,140 MSGET cCliNome Size 120,07  Pixel OF oPanel When .f.

         @ nLinSel+10,007 Say STR0022      Size 40,07 Pixel of oPanel //"Pais"
         @ nLinSel+10,100 Say STR0023 Size 35,07 Pixel of oPanel //"Desc.Pais"

         @ nLinSel+10,35  MSGET cCliCodPais Size 040,07 Pixel OF oPanel When .f.
         @ nLinSel+10,140 MSGET cCliDscPais Size 120,07 Pixel OF oPanel When .f.

         aPos := PosDlgDown(oDlg)
         aPos[1] := 36

         oMsSelect := MsSelect():New("Work2","WKMARCA",,aCpos,@lInverte,@cMarca,aPos)
         oMsSelect:oBrowse:Refresh() //wfs

         dbSelectArea("Work2")
         Set Filter to (Work2->WKMARCA <> '  ')
         Work2->(dbGoTop())

         bOk     := {|| nOpcao := 1, oDlg:End() }
         bCancel := {|| nOpcao := 0, oDlg:End() }

		 oPanel:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		 oMsSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT  //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

	  oDlg:lMaximized:=.T. //Maximiliza Janela
      ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

      dbSelectArea("Work2")
      Set Filter To

      // by CAF 05/08/2002 - Gravar o EE1 no OK (final)
      // If nOpcao == 1
      //    AC100GrvEE1()
      // EndIf

      IF nOpcao == 0
         Break
      Endif

      IF nOpcao == 1 // Ok
         Exit
      Endif
   Enddo

End Sequence

Return

/*
Funcao      : AC100Sel
Parametros  :
Retorno     : Nil
Objetivos   : Selecao de Documentos/Atividades
Autor       : Jeferson Barros Nr.
Data/Hora   : 03/08/2002 09:56
Revisao     :
Obs.        :
*/
STATIC Function AC100Sel()

Local oDlg
Local nLinSel	:= 15
Local aCpos		:= {{"WKMARCA",""," "},;
               {{|| Work2->EE1_DOCUM},"",STR0010},; //"Código"
               {{|| Work2->EE1_FASE+"-"+If(Work2->EE1_FASE="1",STR0011,If(Work2->EE1_FASE="2",STR0012,; //"Todas"###"Processo"
                    If(Work2->EE1_FASE="3",STR0013,STR0014)))},"",STR0015},; //"Embarque"###"Financas"###"Fase"
               {{|| Work2->EE1_TIPDOC},"",STR0016},; //"Tipo"
               {{|| Work2->WK_DESDOC},"",STR0017}}  //"Documentos"

Local i, bOk, bCancel, nOpcao := 0
Local xValue, aPos
Local aButtons:={}
Local oMsSelect

Local cOldFil := Work2->(dbFilter()),;
      bOldFil := &("{|| "+Work2->(dbFilter())+"}")

Begin Sequence

   dbSelectArea("Work2")
   Set Filter To Work2->EE1_PAIS = cCliCodPais  // GFP - 04/12/2013
   Work2->(dbSetOrder(2))
   Work2->(dbGoTop())

   aAdd(aButtons,{"LBTIK",{|| MarkAll("Work2",oMsSelect)},STR0018}) //"Marca/Desmarca Todos"
   aAdd(aButtons,{"WEB",  {|| AC100MarkPais("Work2",oMsSelect)},STR0019}) //"Marcar documentação padrão do país"

   While .t.
      nOpcao := 0
      aTela := {}
      aGets := {}

      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      
         @00,00 MSPANEL oPanel PROMPT "" SIZE 30,45 OF oDlg

         @ nLinSel,007 Say STR0020 Size 65,07 PIXEL OF oPanel //"Codigo"
         @ nLinSel,100 Say STR0021   Size 65,07 PIXEL OF oPanel //"Nome"

         @ nLinSel,35  MSGET cCliCod  Size 040,07  Pixel OF oPanel When .f.
         @ nLinSel,140 MSGET cCliNome Size 120,07  Pixel OF oPanel When .f.

         @ nLinSel+10,007 Say STR0022      Size 40,07 Pixel of oPanel //"Pais"
         @ nLinSel+10,100 Say STR0023 Size 35,07 Pixel of oPanel //"Desc.Pais"

         @ nLinSel+10,35  MSGET cCliCodPais Size 040,07 Pixel OF oPanel When .f.
         @ nLinSel+10,140 MSGET cCliDscPais Size 120,07 Pixel OF oPanel When .f.

         aPos := PosDlgDown(oDlg)
         aPos[1] := 36

         oMsSelect := MsSelect():New("Work2","WKMARCA",,aCpos,@lInverte,@cMarca,aPos)
         oMsSelect:bAval := {|| IF(Empty(Work2->WKMARCA),;
                                   (Work2->WKMARCA := cMarca, Work2->EE1_ORDEM := Str(nOrdem++,AVSX3("EE1_ORDEM",AV_TAMANHO))),;
                                    Work2->WKMARCA := "  ") }
                                    
         oPanel:Align := CONTROL_ALIGN_TOP 
		 oMsSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                                      

         bOk     := {|| nOpcao := 1, oDlg:End() }
         bCancel := {|| nOpcao := 0, oDlg:End() }
      
      oDlg:lMaximized:=.T. //Maximiliza Janela
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

      IF nOpcao == 0
         Break
      Endif

      Exit
   Enddo

End Sequence

IF !Empty(cOldFil)
   Work2->(dbSetFilter(bOldFil,cOldFil))
Endif

Work2->(dbSetOrder(1))
Work2->(dbGoTop())

Return

/*
Funcao      : AC100GrvW2
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Grava Work2 com informacoes do EEA
Autor       : Jeferson Barros Jr.
Data/Hora   : 03/04/2002 10:07
Revisao     :
Obs.        :
*/
*--------------------------*
STATIC Function AC100GrvW2()
*--------------------------*
Local lRet := .t., aOrd:=SaveOrd({"EE1","SYA"})
Local lFiltroIdioma := EasyGParam("MV_AVG0047",,.T.)

Begin Sequence

   IF Work2->(EasyRecCount("Work2")) == 0
      // *** Grava Work2 com os registros do EEA ...
      SYA->(DBSETORDER(1))
      SYA->(DBSEEK(XFILIAL("SYA")+M->A1_PAIS))

      EEA->(dbSeek(xFilial()))
      Do While EEA->(!Eof() .And. EEA_FILIAL == xFilial("EEA"))

         IF (lFiltroIdioma .And. EEA->EEA_IDIOMA = SYA->YA_IDIOMA .Or. !lFiltroIdioma) .And.;
            LEFT(EEA->EEA_TIPDOC,1) <> "3"
            Work2->(dbAppend())
            Work2->EE1_DOCUM  := EEA->EEA_COD
            Work2->EE1_FASE   := EEA->EEA_FASE
            Work2->EE1_TIPDOC := EEA->EEA_TIPDOC
            Work2->WK_DESDOC  := EEA->EEA_TITULO
            // alterar...                        
            IndRegua("EE1","TEE1"+TEOrdBagExt(),"EE1_FILIAL+EE1_TIPREL+EE1_PAIS+EE1_CODCLI+EE1_CLLOJA+EE1_DOCUM+EE1_TIPDOC")  //indice temporario em tabela fisica         
            If EE1->(dbSeek(xFilial("EE1")+TR_ARQ+cCliCodPais+cCliCod+cLojaCli+Work2->EE1_DOCUM+Work2->EE1_TIPDOC))
               Work2->WKMARCA:=cMarca
               Work2->EE1_PAIS := cCliCodPais
               
               If Alltrim(cCliCod) == Alltrim(EE1->EE1_CODCLI) .And. Alltrim(cLojaCli) == Alltrim(EE1->EE1_CLLOJA)
                  Work2->EE1_ORDEM := EE1->EE1_ORDEM	
               Endif	
                             
               IF Val(EE1->EE1_ORDEM) >= nOrdem
                  nOrdem := Val(EE1->EE1_ORDEM)+1
               Endif
               Work2->TRB_ALI_WT:= "EE1"
               Work2->TRB_REC_WT:= EE1->(Recno())
            Else  // GFP - 04/12/2013
               EE1->(DbSetOrder(2))
               If EE1->(dbSeek(xFilial("EE1")+TR_ARQ+Work2->EE1_DOCUM+cCliCodPais))
                  Work2->EE1_PAIS := cCliCodPais
                  Work2->TRB_ALI_WT:= "EE1"
                  Work2->TRB_REC_WT:= EE1->(Recno())
               EndIf
            EndIf
         ENDIF
         EEA->(dbSkip())
      EndDo

      IF Work2->(EasyRecCount("Work2")) == 0
         lRet := .f.
	     HELP(" ",1,"AVG0000061")
         Break
      Endif
   Endif

   Work2->(dbGotop())
End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : MarkAll
Parametros  : cAlias,oMsSelect
Retorno     : NIL
Objetivos   : Marca/Desmarca Todos
Autor       : Jeferson Barros Jr.
Data/Hora   : 03/08/2002 13:09
Obs.        :
*/
*---------------------------------------*
Static Function MarkAll(cAlias,oMsSelect)
*---------------------------------------*
Local cFlag, nRecNo:=0

Begin Sequence
   If Empty(cAlias)
      Break
   EndIf

   cFlag  := IF(!Empty((cAlias)->WKMARCA),Space(2),cMarca)
   nRecNo := (cAlias)->(RecNo())

   (cAlias)->(dbGotop())
   nOrdem := 1
   (cAlias)->(dbEval({|| (cAlias)->WKMARCA := cFlag, IF(!Empty(cFlag),(cAlias)->EE1_ORDEM := Str(nOrdem++,AVSX3("EE1_ORDEM",AV_TAMANHO)),)},{|| .T. }))
   (cAlias)->(dbGoTo(nRecNo))

   oMsSelect:oBrowse:Refresh()

End Sequence

Return NIL

/*
Funcao      : AC100MarkPais
Parametros  : cAlias,oMsSelect
Retorno     : NIL
Objetivos   : Marca todos os documentos obrigatório para o país.
Autor       : Jeferson Barros Jr.
Data/Hora   : 03/08/2002 13:09
Obs.        :
*/
*---------------------------------------------*
Static Function AC100MarkPais(cAlias,oMsSelect)
*---------------------------------------------*
Local nRecNo:=0
Local aOrd := SaveOrd("EE1",1)

Begin Sequence
   If Empty(cAlias)
      Break
   EndIf

   nRecNo:=(cAlias)->(RecNo())
   (cAlias)->(dbGotop())
   nOrdem := 1
   Do While Work2->(!Eof())
      If EE1->(dbSeek(xFilial()+TR_ARQ+cCliCodPais+Work2->EE1_DOCUM))
         Work2->WKMARCA:=cMarca
         Work2->EE1_ORDEM := Str(nOrdem++,AVSX3("EE1_ORDEM",AV_TAMANHO))
      Else
         Work2->WKMARCA:=""
      EndIf
      Work2->(DbSkip())
   EndDo

   (cAlias)->(dbGoto(nRecNo))

   oMsSelect:oBrowse:Refresh()

End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : AC100GrvEE1
Parametros  : Nenhum
Retorno     : nil
Objetivos   : Grava EE1 com informacoes do Work2
Autor       : Jeferson Barros Jr.
Data/Hora   : 03/08/2002 13:27
Revisao     :
Obs.        :
*/
*---------------------------*
STATIC Function AC100GrvEE1()
*---------------------------*
Local aOrd:=SaveOrd("EE1")

Local cCliCod     := M->A1_COD
Local cLojaCli    := M->A1_LOJA
Local cCliCodPais := M->A1_PAIS

Local nInd := 1

Begin Sequence
   IF Work2->(EasyRecCount("Work2")) == 0
      Break
   Endif

   EE1->(DbSetOrder(3))
   EE1->(dbSeek(xFilial()+TR_ARQ+cCliCodPais+cCliCod+cLojaCli))

   While EE1->(!Eof()) .And. EE1->EE1_FILIAL == xFilial("EE1") .And.;
         EE1->EE1_PAIS == cCliCodPais .And. EE1->EE1_CODCLI == cCliCod .And. EE1->EE1_CLLOJA == cLojaCli

      EE1->(RecLock("EE1",.F.))
      EE1->(dbDelete())
      EE1->(MSUnlock())

      EE1->(dbSkip())
   End

   Work2->(dbGoTop())

   While Work2->(!Eof())
      If !Empty(Work2->WKMARCA)
         EE1->(RecLock("EE1",.T.))
         EE1->EE1_FILIAL := xFilial("EE1")
         EE1->EE1_DOCUM  := Work2->EE1_DOCUM
         EE1->EE1_PAIS   := cCliCodPais
         EE1->EE1_TIPREL := TR_ARQ
         EE1->EE1_FASE   := Work2->EE1_FASE
         EE1->EE1_TIPDOC := Work2->EE1_TIPDOC
         EE1->EE1_CODCLI := cCliCod
         EE1->EE1_CLLOJA := cLojaCli
         EE1->EE1_ORDEM  := Str(nInd++,AVSX3("EE1_ORDEM",AV_TAMANHO))
         EE1->(MSUnlock())
      EndIf

      Work2->(dbSkip())
   End

End Sequence

RestOrd(aOrd)

Return NIL
/*
    Funcao   : EECFBDEST(cDESTINO,cTIPO)
    Autor    : Heder M Oliveira
    Data     : 06/07/99 11:06
    Revisao  : 06/07/99 11:06
    Uso      : Validar Destinos
    Recebe   :
    Retorna  :
*/
Function EECFBDEST(cDESTINO,cTipo)
    LOCAL lRET:=.T.
    LOCAL cDESTATU,nORDSYR:=SYR->(INDEXORD())

    BEGIN SEQUENCE
        IF EMPTY(cDESTINO)
            BREAK
        ENDIF
        DO CASE
            CASE cTipo == "1"   ; cDESTATU:=M->A1_DEST_2+M->A1_DEST_3
            CASE cTipo == "2"   ; cDESTATU:=M->A1_DEST_1+M->A1_DEST_3
            CASE cTipo == "3"   ; cDESTATU:=M->A1_DEST_1+M->A1_DEST_2
        ENDCASE

        SYR->(DBSETORDER(4))
        IF ! SYR->(DBSEEK(xFilial("SYR")+cDESTINO))
            HELP(" ",1,"AVG0000058")
            lRET:=.F.
            BREAK
        ENDIF

        IF AT(cDESTINO,cDESTAtu) <> 0
            HELP(" ",1,"AVG0000059")
            lRET:=.F.
            BREAK
        ENDIF
    END SEQUENCE
    SYR->(DBSETORDER(nOrdSYR))
RETURN lRET

/*
Funcao     : EECFBORI()
Parametros : cOrigem - Campo / cTipo - Numero do Campo
Retorno    : Chamada da função de exibição da legenda da mBrowse
Objetivos  : Validar Origens
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 15/10/2014 :: 14:00
*/
Function EECFBORI(cOrigem,cTipo)
    LOCAL lRET:=.T.
    LOCAL cDESTATU,nORDSYR:=SYR->(INDEXORD())

    BEGIN SEQUENCE
        IF EMPTY(cOrigem)
            BREAK
        ENDIF
        DO CASE
            CASE cTipo == "1"   ; cDESTATU:=M->A1_DEST_2+M->A1_DEST_3
            CASE cTipo == "2"   ; cDESTATU:=M->A1_DEST_1+M->A1_DEST_3
            CASE cTipo == "3"   ; cDESTATU:=M->A1_DEST_1+M->A1_DEST_2
        ENDCASE

        //SYR->(DBSETORDER(4)) //LGS-24/11/2014
        SYR->(DBSETORDER(3))
        IF ! SYR->(DBSEEK(xFilial("SYR")+cOrigem))
            HELP(" ",1,"EEC0000001")
            lRET:=.F.
            BREAK
        ENDIF

        IF AT(cOrigem,cDESTAtu) <> 0
            HELP(" ",1,"EEC0000002")
            lRET:=.F.
            BREAK
        ENDIF
    END SEQUENCE
    SYR->(DBSETORDER(nOrdSYR))
RETURN lRET

/*
Funcao      : AC100Crit(cCpo)
Parametros  : cCpo := Campo a ser consistido
Retorno     : .T./.F.
Objetivos   : Gravar Header e mensagens
Autor       : Cristiano A. Ferreira
Data/Hora   : 26/07/99 21:19
Revisao     :
Obs.        :
*/
Function AC100Crit(cCpo)
Local lRet := .T.
Private lValidCli:= lRet

Begin Sequence
   DO CASE
      CASE cCpo == "A1_COMAGE"
         SY5->(dbSeek(xFilial()+M->A1_CODAGE))
         IF !Empty(M->A1_CODAGE) .And. Empty(M->A1_COMAGE) .and. LEFT(SY5->Y5_TIPOAGE,1) = "3"
            Help(" ",1,"AVG0000623") // MsgStop("Agente sem comissão !","Aviso")
            lRet := .F.
            Break
         Endif
   ENDCASE
End Sequence

//DFS - 17/11/10 - Criação de ponto de entrada para validação de navios.
If EasyEntryPoint("EECAC100")
   Execblock("EECAC100",.F.,.F.,{"AC100CRIT_CLIENTES", cCpo})
EndIf

If ValType(lValidCli) == "L"
   lRet:= lValidCli
EndIf

Return lRet

/*
Funcao      : MoveUp(oBrw,cAlias)
Parametros  : oBrw, cAlias
Retorno     : NIL
Objetivos   : Move registro para cima
Autor       : Cristiano A. Ferreira
Data/Hora   : 05/08/2002 17:48
Revisao     :
Obs.        :
*/
Function MoveUp(oBrw,cAlias)

Local nRec := (cAlias)->(RecNo())
Local cSeq := (cAlias)->EE1_ORDEM
Local cSeqOld

Begin Sequence

   (cAlias)->(dbSkip(-1))

   IF (cAlias)->(Bof())
      (cAlias)->(dbGoTo(nRec))
      Break
   Endif

   cSeqOld := (cAlias)->EE1_ORDEM

   (cAlias)->EE1_ORDEM := cSeq

   (cAlias)->(dbGoTo(nRec))
   (cAlias)->EE1_ORDEM := cSeqOld

   oBrw:oBrowse:Refresh()

End Sequence

Return NIL

/*
Funcao      : MoveDown(oBrw)
Parametros  : oBrw
Retorno     : NIL
Objetivos   : Move registro para baixo
Autor       : Cristiano A. Ferreira
Data/Hora   : 05/08/2002 17:50
Revisao     :
Obs.        :
*/
Function MoveDown(oBrw,cAlias)

Local nRec := (cAlias)->(RecNo())
Local cSeq := (cAlias)->EE1_ORDEM
Local cSeqNext

Begin Sequence

   (cAlias)->(dbSkip(1))

   IF (cAlias)->(Eof())
      (cAlias)->(dbGoTo(nRec))
      Break
   Endif

   cSeqNext := (cAlias)->EE1_ORDEM

   (cAlias)->EE1_ORDEM := cSeq

   (cAlias)->(dbGoTo(nRec))
   (cAlias)->EE1_ORDEM := cSeqNext

   oBrw:oBrowse:Refresh()

End Sequence

Return NIL

/*
Funcao      : AC100Adian().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Manutenção de adiantamentos. (Pagamento Antecipado).
Autor       : Jeferson Barros Jr.
Data/Hora   : 04/11/2002 13:30.
Revisao     :
Obs.        :
*/
*-------------------*
// ACSJ - Caetano - 17/01/2005
// Criação do paramentro PlVisual para identificar quando os adiantamentos serão apenas visualizados é usado
// no ECOCAD00
//----------------------------
Function AC100Adian(PlVisual)
*-------------------*
Local lRet := .t., lTemMoeda:=.t.
Local bOk := {|| nOpcao:=1, If(!lEEQAuto, oDlg:End(), )} , bCancel := {|| oDlg:End()}
Local aButtons := {}, aOrd:=SaveOrd({"EEQ","SX3","EXJ"}), aSemSx3:={} //, aCpos := {} TLM 18/02/2008 - Alterado aCposTela e tipo private
Local oDlg, oMsSelect //, oGetSld - GFP - 23/08/2012
Local cArq, cPictDt:="  /  /  ", cPictVl := "@E 999,999,999,999.99", cPictTx := "@E 99,999,999.999999" //NCF - 01/10/2015 - Adiant. com Mov. Exterior
Local cTit, cCliCod, cCliNome, cCliCodPais, cCliDscPais
Local nOpcao := 0
LOCAL oPanel
Local lVisual := iif( Valtype(PlVisual) == "U", .f. , iif(PlVisual == "VISUAL",.t.,.f.) )
Local nInc := 0, aFil := {}, cFil := ""
Local bOnError := {|cFuncName, nOpc| AC100RetAdian(cFuncName, nOpc) }
Local aOrdTabBco := {}
Local i := 0
Local nRecSA1 := SA1->(Recno()) //MCF - 12/01/2017                                                                            //NCF - 01/10/2015 - Adiant. com Mov. Exterior
// ---------------------------

Private aDeletados := {}, nSaldo := 0, aCposTela := {} // TLM 18/02/2008
Private lFinanciamento := EasyGParam("MV_EFF",,.F.)
Private lIntFina := EasyGParam("MV_EEC_EFF",,.F.)
Private aArrayEEQ := {}
Private aRetEEQ := {}

SX3->(DBSETORDER(2))
Private lOkEVENT  := SX3->(dbSeek("EEQ_EVENT"))
Private lLoop := .F.
Private aButtonsAux := {}
Private lGerAdEEC := .F.
If EasyGParam("MV_EFF0006",.T.)
   lGerAdEEC := EasyGParam("MV_EFF0006",,.F.)
EndIf

Private lTelaVincula := .F. //FSM - 01/03/2012

Private aCores := {} //FDR - 27/03/13
Private lCpoAcrDcr := AVFLAGS("ACR_DEC_DES_MUL_JUROS_CAMBIO_EXP") //NCF - 14/08/2015 - Tratamento Acresc./Decres. no controle de cambio SIGAEEC x SIGAFIN
Private lAdtMovExt := AVFLAGS("CAMBIO_EXP_MOV_EXT")      //NCF - 01/10/2015 - Adiant. com Mov. Exterior

Private cBanco    := ""
Private cAgencia  := ""
Private cConta    := ""
Private cMotBx    := ""
Private lGrvAdian := .T.

If Type("INCLUI") <> "L"
    INCLUI := .F.
EndIf
If Type("ALTERA") <> "L"
    ALTERA := .T.
EndIf

AjustaEC6()                                                       //NCF - 01/10/2015 - Adiant. com Mov. Exterior

Begin Sequence

   // ** Verifica a moeda cadastrada para o cliente. (EXJ - Complemento do SA1).
   EXJ->(DbSetOrder(1))
   If EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))
      If Empty(EXJ->EXJ_MOEDA)
         lTemMoeda:=.f.
      EndIf
   Else
      lTemMoeda := .f.
   EndIf

   If !lTemMoeda
      EasyHelp(STR0046+Replic(ENTER,2)+; //"Cliente não possui moeda de negociação cadastrada."
              STR0033+ENTER+; //"Detalhes:"
              STR0047+ENTER+; //"Para o lançamento de adiantamentos, a moeda de negociação "
              STR0048,STR0007) //"deve ser informada."###"Atenção"
      Break
   EndIf

   // ** Colunas para o Browse ...
   aCposTela := {{{|| Work_Pgto->EEQ_EVENT}                ,"",AVSX3("EEQ_EVENT",AV_TITULO)},; //"Evento" //NCF - 02/07/2019
                 {{|| Transf(Work_Pgto->EEQ_PGT,cPictDt)}  ,"",AVSX3("EEQ_PGT"  ,AV_TITULO)},;
                 {{|| Work_Pgto->EEQ_PARC}                 ,"",STR0027},; //"Nro.Parcela"
                 {{|| Work_Pgto->EEQ_MOEDA}                ,"",STR0089},; //"Moeda"   // GFP - 23/08/2012
                 {{|| Transf(Work_Pgto->EEQ_VL,cPictVl)}   ,"",STR0028},; //"Valor"
                 {{|| Transf(Work_Pgto->EEQ_SALDO,cPictVl)},"",STR0029+Space(30)},; //"Saldo"
                 {{|| Work_Pgto->EEQ_FINNUM}               ,"",STR0092}} //"Nro.Título"  // GFP - 10/04/2014


   If EEQ->(FieldPos("EEQ_SLDELI")) > 0
      AAdd(aCposTela, {{|| Transf(Work_Pgto->EEQ_SLDELI,cPictVl)},"",STR0087+Space(30)}) //"Saldo Eliminado"
   EndIf
   //NCF - 14/05/2015
   If AVFLAGS("EEC_LOGIX")
      If EEQ->(FieldPos("EEQ_FFC")) > 0
         AAdd(aCposTela, {{|| Work_Pgto->EEQ_FFC},"",AVSX3("EEQ_FFC",AV_TITULO)} )      //"FFC"
      EndIf
      If EEQ->(FieldPos("EEQ_SEQBX")) > 0
         AAdd(aCposTela, {{|| Work_Pgto->EEQ_SEQBX},"",AVSX3("EEQ_SEQBX",AV_TITULO)} ) //"Seq.Baixa"
      EndIf
   EndIf

   //NCF - 22/07/2015
   IF lCpoAcrDcr
      AAdd(aCposTela, {{|| Transf(Work_Pgto->EEQ_DECRES,cPictVl)},"",AVSX3("EEQ_DECRES",AV_TITULO)} ) //"Decrescimos"
   ENDIF

   //NCF - 01/10/2015 - Adiant. com Mov. Exterior
   IF lAdtMovExt
      AADD(aCposTela, {{|| Work_Pgto->EEQ_MOEBCO}                ,"",AVSX3("EEQ_MOEBCO",AV_TITULO)} )
      AADD(aCposTela, {{|| Transf(Work_Pgto->EEQ_PRINBC,cPictTx)},"",AVSX3("EEQ_PRINBC",AV_TITULO)} )
      AADD(aCposTela, {{|| Transf(Work_Pgto->EEQ_VLMBCO,cPictVl)},"",AVSX3("EEQ_VLMBCO",AV_TITULO)} )
   ENDIF

   If EasyEntryPoint("EECAC100")   // TLM 18/02/2008
      ExecBlock("EECAC100",.F.,.F.,"INCLUI_BROWSE")
   EndIf

   // ** Definição dos botoes da Enchoice Bar.

   //ER - 20/06/2006 às 10:00
   aAdd(aButtons,{"HISTORIC", {|| AC100ViewHist()},STR0038}) //"Histórico"

   If EEQ->(FieldPos("EEQ_SLDELI")) > 0
      aAdd(aButtons,{"S4WB004N", {|| AC100RestOrDel()},STR0086}) //"Elimina/Restaura Saldo"
   EndIf

   aAdd(aButtons,{"RELATORIO" /*"ANALITICO"*/,{|| AC100AdiMan(VIS_DET)},STR0002}) //"Visualizar"

  If .not. lVisual  // ACSJ - Caetano - 17/01/2005     // GFP - 23/08/2012 - Nopado objeto oGetSld
   aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/,     {|| AC100AdiMan(INC_DET),AC100AtuSld(),oMsSelect:oBrowse:Refresh()/*oGetSld:Refresh()*/},STR0003}) //"Incluir"
   aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/,  {|| AC100AdiMan(ALT_DET),AC100AtuSld(),oMsSelect:oBrowse:Refresh()/*,oGetSld:Refresh()*/},STR0004}) //"Alterar"
   aAdd(aButtons,{"EXCLUIR",  {|| AC100AdiMan(EXC_DET),AC100AtuSld(),oMsSelect:oBrowse:Refresh()/*,oGetSld:Refresh()*/},STR0005}) //"Excluir"
   //Baixa Gerencial - RMD - 08/11/07
   If EECFlags("CAMBIO_EXT")
      aAdd(aButtons,{"BUDGET",{|| AC100AdiMan(BXG_DET) },"Baixa Gerencial"/*, "Bx. Geren."*/})
   EndIf
  Endif             // ACSJ - Caetano - 17/01/2005

   aCampos:= Array(EEQ->(fCount()))

   aAdd(aSemSx3,{"EEQ_PREEMB","C",AvSx3("EEQ_PREEMB",AV_TAMANHO),AvSx3("EEQ_PREEMB",AV_DECIMAL)})
   aAdd(aSemSx3,{"EEQ_FINNUM","C",AvSx3("EEQ_FINNUM",AV_TAMANHO),AvSx3("EEQ_FINNUM",AV_DECIMAL)})  // GFP - 10/04/2014

   AddNaoUsado(aSemSx3, "EEQ_FFC")                                                                 // NCF - 14/05/2015

   Aadd(aSemSx3,{"RECNO","N",10,0})
   //TRP - 25/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   cArq   := E_CriaTrab("EEQ",aSemSx3,"Work_Pgto")
   IndRegua("Work_Pgto",cArq+TEOrdBagExt(),"EEQ_FASE+EEQ_PREEMB+EEQ_PARC",,,STR0009) //"Processando Arquivo Temporário..."
   Set Index To (cArq+TEOrdBagExt())

   aFil := AvgSelectFil(!lEEQAuto,"EEQ")//AOM - 20/07/2011

   EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
   //EEQ->(DbSeek(xFilial("EEQ")+"C"+AvKey(AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA),"EEQ_PREEMB")))
   For nInc := 1 to Len(aFil)

      EEQ->(DbSeek(aFil[nInc]+"C"+AvKey(SA1->A1_COD+SA1->A1_LOJA,"EEQ_PREEMB")))

      Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == aFil[nInc] .And.;
                                   EEQ->EEQ_FASE   == "C" .And.;
                                   EEQ->EEQ_PREEMB == AvKey(SA1->A1_COD+SA1->A1_LOJA,"EEQ_PREEMB")// EEQ->EEQ_PREEMB == AvKey(AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA),"EEQ_PREEMB")
         If EEQ->EEQ_TIPO = "A"

            //RMD - 11/05/12 - Carrega variáveis do banco para evitar erro no MsSeek
            RegToMemory("EEQ", .F.)

            Work_Pgto->(DbAppend())

            AvReplace("EEQ","Work_Pgto")
            Work_Pgto->RECNO := EEQ->(RecNo())
            Work_Pgto->TRB_ALI_WT:= "EEQ"
            Work_Pgto->TRB_REC_WT:= EEQ->(Recno())

            SA1->(DbGoTo(nRecSA1)) // MCF-12/01/2017 - RegToMemory estava desposicionando a tabela SA1
            
            If lAdtMovExt                                                           //NCF - 01/10/2015 - Adiant. com Mov. Exterior
               aOrdTabBco := SaveOrd("SA6")
               SA6->(DbSetOrder(1))
               If EasyVerModal("Work_Pgto")
                  SA6->(DbSeek(xFilial()+Work_Pgto->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT)))
                  Work_Pgto->EEQ_MOEBCO := SA6->A6_MOEEASY
                  Work_Pgto->EEQ_PRINBC := Work_Pgto->EEQ_VLMBCO/Work_Pgto->EEQ_VL
               Else
                  SA6->(DbSeek(xFilial()+Work_Pgto->(EEQ_BANC+EEQ_AGEN+EEQ_NCON)))
                  Work_Pgto->EEQ_MOEBCO := EasyGParam("MV_SIMB"+CValToChar(SA6->A6_MOEDA),,"")
               EndIf
               RestOrd(aOrdTabBco,.T.)
            EndIf

            // ** Acumula o saldo.
            nSaldo += Work_Pgto->EEQ_SALDO
         EndIf

         EEQ->(DbSkip())
      EndDo
   Next

   Work_Pgto->(DbGoTop())

    // ** Set das variaveis
   cTit        := STR0030 //"Clientes"
   cCliCod     := SA1->A1_COD
   cLojaCli    := SA1->A1_LOJA
   cCliNome    := SA1->A1_NOME
   cCliCodPais := SA1->A1_PAIS
   cCliDscPais := Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_NOIDIOM")
   aTela := {} ;  aGets := {}

   If EasyEntryPoint("EECAC100")
      ExecBlock("EECAC100",.F.,.F.,"ANTES_TELA_ADIAN")
   EndIf

   DO WHILE .T.
      nOpcao:= 0
      If !lEEQAuto
         DEFINE MSDIALOG oDlg TITLE cTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

           @00,00 MSPANEL oPanel PROMPT "" SIZE 30,45 OF oDlg // --- ACSJ - 30/03/2004

           @ 15,007 Say STR0020 Size 65,07 PIXEL Of oPanel //"Codigo"
           @ 15,90 Say "Loja" Size 65,07 PIXEL Of oPanel //"Loja" //MCF - 12/01/2017
           @ 15,140 Say STR0021 Size 65,07 PIXEL Of oPanel //"Nome"
           //@ 15,270 Say STR0029 Size 65,07 PIXEL Of oPanel  //"Saldo"    // Nopado por GFP - 23/08/2012

           @ 15,35  MSGET cCliCod  Size 040,07  Pixel Of oPanel When .f.
           @ 15,110 MSGET cLojaCli Size 010,07  Pixel Of oPanel When .f. //MCF - 12/01/2017
           @ 15,180 MSGET cCliNome Size 120,07  Pixel Of oPanel When .f.

           //@ 15,300 MSGET oGetSld VAR nSaldo   PICTURE AvSx3("EEQ_SALDO",AV_PICTURE) Size 60,07  Pixel Of oPanel When .f.     // Nopado por GFP - 23/08/2012

           @ 25,007 Say STR0022 Size 40,07 Pixel of oPanel //"Pais"
           @ 25,140 Say STR0023 Size 35,07 Pixel of oPanel //"Desc.Pais"

           @ 25,35  MSGET cCliCodPais Size 040,07 Pixel Of oPanel When .f.
           @ 25,180 MSGET cCliDscPais Size 120,07 Pixel Of oPanel When .f.

           aPos := PosDlgDown(oDlg)
           aPos[1] := 46

//		   crf - 04/10/2010 - 16:01
           aCposTela := AddCpoUser(aCposTela,"EEQ","5","Work_Pgto")

           //DFS - 01/04/13 - Inclusão de array auxiliar private, que receberá o conteúdo do aButtons para utilização em Ponto de Entrada.
           aButtonsAux := aClone(aButtons)
           //FDR - 27/03/13 - PE para incluir legenda nas parcelas de adiatamento
           IF (EasyEntryPoint("EECAC100"),Execblock("EECAC100",.F.,.F.,"LEGENDA"),)
           aButtons := aClone(aButtonsAux)
           //DFS - 01/04/13 - Retorno do array auxiliar private para o array aButtons, para que, retorne as informações customizadas.

           oMsSelect := MsSelect():New("Work_Pgto",,,aCposTela,,,aPos,,,,,aCores)
           oMsSelect:bAval := {|| AC100AdiMan(VIS_DET)}
		   oPanel:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
		   oMsSelect:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

         ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
      Else
         If nOpcEEQ == 3
            nOpcEEQ := INC_DET
            If (nPosParc := aScan(aEEQAuto, {|x| x[1] == "EEQ_PARC" })) > 0
               EasyHelp(STR0095, STR0040) //"Erro na execução da rotina automática. Foi informado um código de parcela (EEQ_PARC), porém a numeração da parcela é automática e este campo não deve ser informado na inclusão."###"Aviso"
            EndIf
         ElseIf nOpcEEQ == 4 .Or. nOpcEEQ == 5
            If (nPosFase := aScan(aEEQAuto, {|x| x[1] == "EEQ_FASE" })) == 0
               aAdd(aEEQAuto, {"EEQ_FASE", "C", Nil})
            ElseIf Alltrim(aEEQAuto[nPosFase][2]) <> "C"
               EasyHelp(STR0096, STR0040) //"Erro na execução da rotina automática. A fase (EEQ_FASE) informada é inválida."###"Aviso"
            EndIf
            If (nPosPreemb := aScan(aEEQAuto, {|x| x[1] == "EEQ_PREEMB" })) == 0
               aAdd(aEEQAuto, {"EEQ_PREEMB", SA1->A1_COD+SA1->A1_LOJA, Nil})
            ElseIf AllTrim(aEEQAuto[nPosFase][2]) <> AllTrim(SA1->A1_COD+SA1->A1_LOJA)
               EasyHelp(STR0097, STR0040) //"Erro na execução da rotina automática. A chave (EEQ_PREEMB) informada não corresponde ao cliente."###"Aviso"
            EndIf
            If (nPosParc := aScan(aEEQAuto, {|x| x[1] == "EEQ_PARC" })) == 0
               EasyHelp(STR0098, STR0040) //"Erro na execução da rotina automática. Não foi informada a parcela (EEQ_PARC)."###"Aviso"
            ElseIf !EasySeekAuto("Work_Pgto", aEEQAuto, 1)
               EasyHelp(StrTran(STR0099, "XXX", AllTrim(aEEQAuto[nPosParc][2])), STR0040) //"Erro na execução da rotina automática. A parcela informada ('XXX') não foi localizada."###"Aviso"
            EndIf
            If nOpcEEQ == 4
               nOpcEEQ := ALT_DET
            Else
               nOpcEEQ := EXC_DET
            EndIf
         Else
            EasyHelp(STR0100, STR0040) //"Erro na execução da rotina automática. Opção Inválida"###"Aviso"
         EndIf
         If !lMsErroAuto
            If AC100AdiMan(nOpcEEQ)
                Eval(bOK)
            EndIf
         EndIf
      EndIf

    If nOpcao = 1

        lLoop:=.F.
        IF EasyEntryPoint("EECAC100") // AWR - 16/05/2006
            ExecBlock("EECAC100",.F.,.F.,"ANTES_GRAVA")
        Endif
        IF lLoop
            Loop
        EndIf

        EasyEAIBuffer("INICIO")
        Begin Transaction
        
            Processa({|| lRet := GravaAdian()})

            If __lSX8
                ConfirmSX8()
            Endif

        End Transaction
        If !lRet
            EasyElinkError("FIN", !lEEQAuto)
        EndIf
        ELinkClearID()
        EasyEAIBuffer("FIM",bOnError)

    Else
        If __lSX8
            RollBackSX8()
        Endif
    Endif

    Exit

EndDo

End Sequence

If Select("Work_Pgto") > 0
   Work_Pgto->(E_EraseArq(cArq))
EndIf

RestOrd(aOrd)

Return lRet
/*
Funcao      : AC100RetAdian(cFuncName, nOpc)
Parametros  : nTipo  := VIS_DET/INC_DET/ALT_DET/EXC_DET
Retorno     : .T.
Objetivos   : Manutencao de adiantamentos. - (Pagamentos Antecipados)
Autor       : Jeferson Barros Jr.
Data/Hora   : 04/11/02 17:06
Obs.        :
*/
Static Function AC100RetAdian(cFuncName, nOpc)

Local nW, j

    ClrBufADP(EEQ->(Recno()))
    // MPG - 10/07/2018 - Estornar ação de exclusão quando a integração com Logix retornar erro
    iF nOpc == 5
        
       If ( nW := aScan(aRetEEQ,{|x| x[1] == EEQ->(Recno()) }) )  > 0  //For nW := 1 to len(aRetEEQ)
            //EEQ->( dbgoto( aRetEEQ[nW][1] ) )
            EEQ->(RecLock("EEQ",.F.))
            If EEQ->(Deleted())
               EEQ->(dbRecall())
            EndIf
            j := 1
            aEval( aRetEEQ[nW][2],{|x| EEQ->&(EEQ->(FIELDNAME(j))) := x , j++ })
            EEQ->(MsUnlock())
       EndIf //Next

    ElseIf nOpc == 3

        EEQ->(RecLock('EEQ',.F.))
        EEQ->EEQ_PGT  := cToD("  /  /  ")
        EEQ->EEQ_NROP := AvKey("","EEQ_NROP")
        EEQ->EEQ_TX   := 0
        EEQ->EEQ_EQVL := 0
        EEQ->(MsUnLock())

    EndIf

Return
/*
Funcao      : AC100AdiMan(nTipo)
Parametros  : nTipo  := VIS_DET/INC_DET/ALT_DET/EXC_DET
Retorno     : .T.
Objetivos   : Manutencao de adiantamentos. - (Pagamentos Antecipados)
Autor       : Jeferson Barros Jr.
Data/Hora   : 04/11/02 17:06
Obs.        :
*/
*---------------------------------------*
Static Function AC100AdiMan(nTipoLocal)
*---------------------------------------*
Local bOk:={|| nOpcao := 1, If(AC100Valid(nTipo,nReg),If(!lEEQAuto, oDlg:End(), ),nOpcao:=0)}, bCancel:={|| oDlg:End()}
Local aPos := {}, aSemSx3 := {}
Local cTit := STR0031  //"Manutenção de Adiantamentos."
Local nOpcao := 0, nReg, i:=0
Local nRecSA1 := SA1->(Recno())
Local oMsmGet1
Local lAdLiquidado
Local aOrdEEQ := {}
Local aOptionMBrw := {INCLUI,ALTERA}   //NCF - 01/10/2015 - Adiant. com Mov. Exterior(opcoes vêm como .F. por não ser chamada da MBrowse como é na rotina AP100AdiMan)
local aFields   := {}
local lVirtCpo  := .F.
local lUserCpo  := .F.

// ** JPM - 14/01/2010 - Colocada como private para ser acessada pelo pto de entrada
// Local aAltera
PRIVATE lRet := .T.
Private aAltera
Private aEnchoice := {}, aGets:={}, aTela:={}, aButtons:={}, nTipo:=nTipoLocal
Private lEmbarcado := .F. // By JPP - 12/10/2006 - 10:00 - .F. - Informa que a manutenção de câmbio está sendo
                          // realizada sem a realização de um embarque. É o caso dos adiantamentos. Variável utilizada na validação do câmbio AF200Valid()
Private cAdiMoeda := "" // utilizada no fonte EECAF200
Private nOpcAdClPd := If( nTipoLocal == 5, 4 , If(nTipoLocal == 4,5,nTipoLocal)  ) //NCF - 01/10/2015 - Adiant. com Mov. Exterior

If lAdtMovExt             //NCF - 01/10/2015 - Adiant. com Mov. Exterior(Altera opções nas variáveis da MBrowse)
   If nTipoLocal == ALT_DET .Or. nTipoLocal == BXG_DET
      INCLUI := .F.
      ALTERA := .T.
   ElseIf nTipoLocal == INC_DET
      INCLUI := .T.
      ALTERA := .F.
   EndIf
EndIf

Begin Sequence

   IF nTipo != INC_DET .And. Work_Pgto->(Eof()) .AND. Work_Pgto->(Bof())
      HELP(" ",1,"AVG0000632") // Não existem registros para a manutenção !
      Break
   EndIf

   If (nTipo == ALT_DET .Or. nTipo == EXC_DET .Or. nTipo == BXG_DET) .AND. !Empty(Work_Pgto->EEQ_PGT)  // GFP - 29/08/2012
      If Work_Pgto->EEQ_VL <> Work_Pgto->EEQ_SALDO .OR. If( AVFLAGS("EEC_LOGIX"), !Empty(Work_Pgto->EEQ_FFC) , .F. ) // NCF - 14/05/2015 - Verificação de FFC (Integ. Logix)
         If nTipo == ALT_DET .Or. nTipo == BXG_DET
            EasyHelp(STR0032+Replic(ENTER,2)+; //"Este adiantamento não pode ser alterado."
                    STR0033+ENTER+;  //"Detalhes:"
                    STR0034+ENTER+;  //"Este adiantamento já está vinculado a invoice(s), para alterar o mesmo "
                    STR0035,STR0007) //"favor desvincular o adiantamento na{s) invoice(s) correspondente(s)."###"Atenção"
         Else
            EasyHelp(STR0036+Replic(ENTER,2)+; //"Este adiantamento não pode ser excluido."
                    STR0033+ENTER+;  //"Detalhes:"
                    STR0037+ENTER+;  //"Este adiantamento já está vinculado a invoice(s), para excluir o mesmo "
                    STR0035,STR0007) //"favor desvincular o adiantamento na{s) invoice(s) correspondente(s)."###"Atenção"
         EndIf
         Break
      EndIf

      If EECFlags("CAMBIO_EXT")
         //WFS 12/04/2010
         M->EEQ_AGCEXT:= Work_Pgto->EEQ_AGCR
         M->EEQ_CNTEXT:= Work_Pgto->EEQ_CCCRED
         M->EEQ_NBCEXT:= Work_Pgto->EEQ_NBCOCR
      EndIf

   EndIf

   If nTipo == EXC_DET
      //FSM - 05/10/2012
      If EasyIsVincAdiant(nTipo, Work_Pgto->EEQ_NRINVO, Work_Pgto->EEQ_PARC)
         Break
      EndIf

      ///////////////////////////////////////////////////////////////////////////////////
      //ER - 03/09/2008.                                                               //
      //Para adiantamentos originados em contratos de financiamento, não será permitido//
      //a exclusão manual.                                                             //
      ///////////////////////////////////////////////////////////////////////////////////
      If lGerAdEEC
         If Work_Pgto->EEQ_FAOR == "F"
            MsgStop(STR0032+Replic(ENTER,2)+; //"Este adiantamento não pode ser alterado."
                    STR0033+ENTER+;  //"Detalhes:"
                    STR0081+ENTER+;  //"Este adiantamento está vinculado a contrato de financiamento, para excluir o mesmo "
                    STR0082,STR0007) //"favor estornar o contrato de financiamento correspondente."###"Atenção"
            Break
         EndIf
      EndIf
   EndIf

   IF EasyEntryPoint("EECAC100") // AWR - 16/05/2006
      ExecBlock("EECAC100",.F.,.F.,"VALID_MAN")
   Endif
   If !lRet
      Break
   EndIf

   // ** Campos da enchoice.      // GFP - 23/08/2012 - Inclusao do campo de Moeda // GFP - 23/08/2012 - Inclusao do campo de Nro.Titulo
   aEnchoice:={"EEQ_EVENT","EEQ_MOEDA","EEQ_VL"  ,"EEQ_NROP"  ,"EEQ_PGT"   ,"EEQ_TX"  ,"EEQ_BANC"  ,"EEQ_AGEN"  ,;                       //NCF - 04/07/2019
               "EEQ_NCON" ,/*"EEQ_NOME",*/"EEQ_NOMEBC","EEQ_CORR"  ,"EEQ_EQVL",/*"EEQ_VLCORR",*/;
               "EEQ_DECAM","EEQ_RFBC","EEQ_DTCE"  ,"EEQ_NRINVO","EEQ_OBS" ,"EEQ_SOL"   ,"EEQ_DTNEGO", "EEQ_FINNUM"}
   If EEQ->(FieldPos("EEQ_VLCORR")) > 0
      aAdd(aEnchoice, "EEQ_VLCORR")
   EndIf
   If EEQ->(FieldPos("EEQ_NOME")) > 0
      aAdd(aEnchoice, "EEQ_NOME")
   EndIf
   If lAdtMovExt                     //NCF - 01/10/2015 - Adiant. com Mov. Exterior
      Aadd(aEnchoice,"EEQ_MODAL" )
      Aadd(aEnchoice,"EEQ_BCOEXT")
      Aadd(aEnchoice,"EEQ_CNTEXT")
      Aadd(aEnchoice,"EEQ_AGCEXT")
   EndIf
   // ** Variaveis para evitar erros nos gatilhos.
   M->EEC_NRINVO := ""
   M->EEQ_VM_REC := 0

   If nTipo == INC_DET
      For i := 1 TO EEQ->(FCount())
         M->&(EEQ->(FieldName(i))) := CriaVar(EEQ->(FieldName(i)))
      Next

      //WFS - 01/10/2012
      M->EEQ_MOEDA:= EXJ->EXJ_MOEDA
      M->EEQ_EVENT:= "605"          //NCF - 02/07/2019 - Inicializa automaticamente com esse valor que pode ser alterado por F3.
   Else
      For i := 1 TO Work_Pgto->(FCount())
         M->&(Work_Pgto->(FieldName(i))) := Work_Pgto->(FieldGet(i))
      Next
      if nTipo == VIS_DET .and. EasyVerModal("M")
         M->EEQ_BANC := ""
         M->EEQ_AGEN := ""
         M->EEQ_NCON := ""
         M->EEQ_NOMEBC := ""
      endif
      // ** Exibe o botão de histórico apenas para os adiantamentos que possuem algum vinculo.
      If Work_Pgto->EEQ_SALDO <> Work_Pgto->EEQ_VL
         aAdd(aButtons,{"HISTORIC",{|| AC100ViewHist()},STR0038}) //"Histórico"
      EndIf
   EndIf

   aFields := FWSX3Util():GetAllFields("EEQ", .T.)
   for i := 1 To Len(aFields)

      lVirtCpo := GetSx3Cache(aFields[i], "X3_CONTEXT") == "V"
      lUserCpo := GetSx3Cache(aFields[i], "X3_PROPRI") == "U"
      if lVirtCpo .or. lUserCpo

         if Work_Pgto->(ColumnPos(aFields[i])) == 0 .or. nTipo == INC_DET
            M->&(aFields[i]) := CriaVar(aFields[i])
         else
            M->&(aFields[i]) := Work_Pgto->&(aFields[i])
         endif

         if( lUserCpo , aAdd(aEnchoice, aFields[i]), nil) 

      endif

   next

   SA1->(DbGoTo(nRecSA1))//Evita que algum inicializador padrão desposicione o SA1
   // campos necessários para o gatilho do campo EEQ_PGT na função AF200LoadCpo
   M->EEQ_IMPORT := SA1->A1_COD
   M->EEQ_IMLOJA := SA1->A1_LOJA

   nReg := Work_Pgto->(RecNo())

   //NCF - 01/10/2015 - Adiant. com Mov. Exterior
   If lAdtMovExt
      M->EEQ_MOEDA  := EXJ->EXJ_MOEDA
      //M->EEQ_EVENT  := "605"  //NCF - 02/07/2019 - Assumir o que foi gravado no registro
   EndIf

   // JPM - 27/03/06 - Ponto de entrada para validar se o usuário terá acesso à manutenção, e alterar variáveis.
   If EasyEntryPoint("AC100ADIAN")
      If ValType((lRet := ExecBlock("AC100ADIAN",.F.,.F.,{"VALID_MAN",nTipo}))) <> "L"
         lRet := .T.
      EndIf
      If !lRet
         Break
      EndIf
   EndIf

   //RMD - 10/11/07
   If nTipo == VIS_DET .Or. nTipo == EXC_DET
      aAltera := {}
   ElseIf nTipo == BXG_DET
      aAltera := {}
      aEnchoice := {}
      aAdd(aEnchoice, IncSpace("EEQ_DTCE", Len(SX3->X3_CAMPO), .F.))
      // ** JPM - 14/01/2010 - deve permitir a baixa gerencial se não estiver paga.
      If Empty(M->EEQ_PGT)
         aAdd(aAltera, IncSpace("EEQ_DTCE"  , Len(SX3->X3_CAMPO), .F.))
      EndIf
      aAdd(aAltera, IncSpace("EEQ_CONTMV", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_BCOEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_CNTEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_AGCEXT", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_NBCEXT", Len(SX3->X3_CAMPO), .F.))
   ElseIf nTipo == ALT_DET .AND. Empty(M->EEQ_PGT) // GFP - 29/08/2012 - Permitir alteração dos campos apenas se data de liquidação estiver vazia.
      aAltera := {}
      aAdd(aAltera, IncSpace("EEQ_DTCE"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_SOL"   , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_DTNEGO", Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_PGT"   , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_DECAM" , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_NROP"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_TX"    , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_EEQVL" , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_BANC"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_AGEN"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_NCON"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_RFBC"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_CORR"  , Len(SX3->X3_CAMPO), .F.))
      aAdd(aAltera, IncSpace("EEQ_OBS"   , Len(SX3->X3_CAMPO), .F.))
     //DFS - 08/11/12 - Caso a data de pagamento esteja preenchida, sistema permite apenas alterar a data de pagamento.
   ElseIf nTipo == ALT_DET .AND. !Empty(M->EEQ_PGT)
      aAltera := {}
      If lAdtMovExt .And. EasyVerModal('M')                             //NCF - 01/10/2015 - Adiant. com Mov. Exterior
         aAdd(aAltera, IncSpace("EEQ_DTCE"   , Len(SX3->X3_CAMPO), .F.))
         nOpcAdClPd := 5
      Else
         aAdd(aAltera, IncSpace("EEQ_PGT"   , Len(SX3->X3_CAMPO), .F.))
         If IsIntEnable("001")
            AAdd(aAltera, IncSpace("EEQ_MOTIVO", Len(SX3->X3_CAMPO), .F.))
         EndIf
      EndIf
   Else
      aAltera := aClone(aEnchoice)
      If EECFlags("CAMBIO_EXT")
         If aScan(aAltera, "EEQ_DTCE") > 0
            aDel(aAltera, aScan(aAltera, "EEQ_DTCE"))
            aSize(aAltera, Len(aAltera) - 1)
         EndIf
      EndIf
      If aScan(aAltera, "EEQ_FINNUM") > 0  // GFP - 10/04/2014
         aDel(aAltera, aScan(aAltera, "EEQ_FINNUM"))
         aSize(aAltera, Len(aAltera) - 1)
      EndIf
   EndIf

   If nTipo == INC_DET //LRS - 4/4/2014 - adicionar o campo EEQ_DTCE ao array aAltera quando foi incluir.
     If EasyGParam("MV_AVG0144",,.f.)
       aAdd(aAltera, IncSpace("EEQ_DTCE"   , Len(SX3->X3_CAMPO), .F.))
     EndIF
     If IsIntEnable("001") .And. aScan(aAltera, "EEQ_MOEDA") > 0
        aDel(aAltera, aScan(aAltera, "EEQ_MOEDA"))
        aSize(aAltera, Len(aAltera) - 1)
     EndIf
   EndIF

   //RMD - 10/11/07 - Baixa Gerencial
   If EECFlags("CAMBIO_EXT")
      aAdd(aEnchoice, IncSpace("EEQ_CONTMV", Len(SX3->X3_CAMPO), .F.))
      aAdd(aEnchoice, IncSpace("EEQ_BCOEXT" , Len(SX3->X3_CAMPO), .F.))
      aAdd(aEnchoice, IncSpace("EEQ_CNTEXT" , Len(SX3->X3_CAMPO), .F.))
      aAdd(aEnchoice, IncSpace("EEQ_AGCEXT" , Len(SX3->X3_CAMPO), .F.))
      aAdd(aEnchoice, IncSpace("EEQ_NBCEXT" , Len(SX3->X3_CAMPO), .F.))
   EndIf

   //FSM - 05/10/2012
   If nTipo == ALT_DET .And. EasyIsVincAdiant(nTipo, M->EEQ_NRINVO, M->EEQ_PARC, .F.)
      If aScan(aAltera, "EEQ_NRINVO") > 0
         aDel(aAltera, aScan(aAltera, "EEQ_NRINVO"))
         aSize(aAltera, Len(aAltera) - 1)
      EndIf
      If aScan(aAltera, "EEQ_NROP") > 0
         aDel(aAltera, aScan(aAltera, "EEQ_NROP"))
         aSize(aAltera, Len(aAltera) - 1)
      EndIf
      If aScan(aAltera, "EEQ_VL") > 0
         aDel(aAltera, aScan(aAltera, "EEQ_VL"))
         aSize(aAltera, Len(aAltera) - 1)
      EndIf
   EndIf

   IF lCpoAcrDcr
     Aadd(aEnchoice,"EEQ_DECRES")
     If nTipo == INC_DET .Or. ( nTipo == ALT_DET .And. Empty(M->EEQ_PGT) )
        aAdd(aAltera, IncSpace("EEQ_DECRES"  , Len(SX3->X3_CAMPO), .F.))
     EndIf
   ENDIF

   IF lAdtMovExt        //NCF - 01/10/2015 - Adiant. com Mov. Exterior
     Aadd(aEnchoice,"EEQ_PRINBC")
     Aadd(aEnchoice,"EEQ_VLMBCO")
     Aadd(aEnchoice,"EEQ_MOEBCO")
     If nTipo == INC_DET .Or. ( nTipo == ALT_DET .And. Empty(M->EEQ_PGT) )
        aAdd(aAltera, IncSpace("EEQ_PRINBC"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_VLMBCO"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_MODAL"   , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_BCOEXT"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_CNTEXT"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_AGCEXT"  , Len(SX3->X3_CAMPO), .F.))
        aAdd(aAltera, IncSpace("EEQ_MOTIVO"  , Len(SX3->X3_CAMPO), .F.))
     EndIf
   ENDIF

   IF EasyEntryPoint("EECAC100") // JPM - 14/01/2010 - Ponto de entrada antes da tela.
      ExecBlock("EECAC100",.F.,.F.,"ANTES_TELA_MANUT_PARC")
   Endif

   If !lEEQAuto
      DEFINE MSDIALOG oDlg TITLE cTit FROM 9,0 TO 35,80 OF oMainWnd
         aPos := PosDlg(oDlg)

         //RMD - 10/11/07
         //EnChoice("EEQ",,IF(nTipo=INC_DET,3,4),,,,aEnchoice,aPos,IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)
         //EnChoice("EEQ",,IF(nTipo=INC_DET,3,4),,,,aEnchoice,aPos,aAltera,3) //comentado por wfs
         oMsmGet1:= MsmGet():New("EEQ",,IF(nTipo=INC_DET,3,4),,,,aEnchoice,aPos,aAltera,3)
         oMsmGet1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED
   Else
      EasyEnchAuto("EEQ",aEEQAuto,{|| Obrigatorio(aGets,aTela)},IF(nTipo=INC_DET,3,4), aEnchoice,aAltera)
      If !lMsErroAuto
         Eval(bOk)
       EndIf
   EndIf

   If nOpcao = 1
      If nTipo == INC_DET
         Work_Pgto->(DbAppend())
         nReg := Work_Pgto->(RecNo())
         AvReplace("M","Work_Pgto")
         Work_Pgto->EEQ_PREEMB := SA1->A1_COD+SA1->A1_LOJA
         Work_Pgto->TRB_ALI_WT:= "EEQ"
         Work_Pgto->TRB_REC_WT:= EEQ->(Recno())
         //Work_Pgto->EEQ_PREEMB := AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA)
         Work_Pgto->EEQ_FASE   := "C"
         Work_Pgto->EEQ_TIPO   := "A"
         Work_Pgto->EEQ_PARC   := CalcParc(Work_Pgto->EEQ_PREEMB, Work_Pgto->EEQ_FASE) //AAF 06/01/2017 - Gerar parcela unica independente de filial.
         Work_Pgto->EEQ_SALDO  := Work_Pgto->EEQ_VL
         Work_Pgto->(DbGoTop())
      ElseIf nTipo == ALT_DET .Or. nTipo == BXG_DET
         AvReplace("M","Work_Pgto")
         //NCF - 28/07/2015 - tem que comparar com a tabela aqui pra saber se a cambial está liquidada, pois pode
         //                   ter alterado o campo na Enchoice sem ter confirmado a rotina.
         aOrdEEQ := SaveOrd("EEQ")
         EEQ->(DbSetORder(6))
         lAdLiquidado := EEQ->(DbSeek(   Work_Pgto->(xFilial('EEQ') + EEQ_FASE + EEQ_PREEMB + EEQ_PARC) )) .And. !Empty( EEQ->EEQ_PGT )
         RestOrd(aOrdEEQ,.T.)
         If /*Empty(Work_Pgto->EEQ_PGT)*/ !lAdLiquidado    // GFP - 31/08/2012
            Work_Pgto->EEQ_SALDO  := Work_Pgto->EEQ_VL
         EndIf
         Work_Pgto->(DbGoTop())
      EndIf

   EndIf

End Sequence

INCLUI := aOptionMBrw[1]  //NCF - 01/10/2015 - Adiant. com Mov. Exterior (restaura opcoes da MBrowse)
ALTERA := aOptionMBrw[2]

Return lRet

/*
Funcao      : AC100Valid(nTipo,nReg).
Parametros  : nTipo => Opcao
              nReg  => Nro. Registro.
Retorno     : .t./.f.
Objetivos   : Efetuar validação dos campos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/02 08:50.
Obs.        :
*/
*------------------------------------*
Static Function AC100Valid(nTipo,nReg)
*------------------------------------*
Local lRet:=.t.

Begin Sequence

   If Str(nTipo,1) $ Str(INC_DET,1)+"/"+Str(ALT_DET,1)

      If !Obrigatorio(aGets,aTela)
         lRet := .f.
         Break
      Endif

      If M->EEQ_VL == 0
         EasyHelp(STR0039,STR0040) //"Valor do adiantamento inválido."###"Aviso"
         lRet:=.f.
         Break
      EndIf
      //*** RMD - 19/12/07 - Validação do banco
      If !Empty(M->EEQ_BANC) .Or. !Empty(M->EEQ_AGEN) .Or. !Empty(M->EEQ_NCON)
         SA6->(DbSetOrder(1))
         If !(lRet := SA6->(DbSeek(xFilial() + AvKey(M->EEQ_BANC,"EEQ_BANC") + AvKey(M->EEQ_AGEN,"EEQ_AGEN") + AvKey(M->EEQ_NCON,"EEQ_NCON"))))
            EasyHelp(STR0101 + ENTER + STR0102, STR0016)//"A conta informada não existe no cadastro de bancos."### "Escolha uma conta válida." ###"Aviso"
            Break
         EndIf
      EndIf
      //***

      If !Empty(M->EEQ_PGT)
         // ** Valida a Taxa
         If M->EEQ_TX = 0
            EasyHelp(STR0065,STR0007) //"A taxa utilizada para fechamento de câmbio deve ser informada."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida o numero da operação.
         If !Empty(M->EEQ_PGT) .AND. Empty(M->EEQ_NROP)
            EasyHelp(STR0066,STR0007) //"Número da operação deve ser informado."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida a moeda da operação.    // GFP - 31/08/2012
         If Empty(M->EEQ_MOEDA)
            EasyHelp(STR0090,STR0007) //"A moeda deve ser informada."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida o codigo do banco.
         If !Empty(M->EEQ_PGT) .AND. If(lAdtMovExt .And. EasyVerModal('M'),Empty(M->EEQ_BCOEXT),Empty(M->EEQ_BANC))  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
            EasyHelp(STR0067,STR0007) //"O banco utilizado para fechamento de câmbio deve ser informado."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         If EECFlags("CAMBIO_EXT")
            // ** Valida a data de créd ext.
            If Empty(M->EEQ_DTCE)
               EasyHelp(STR0103,STR0007) //"Antes da liquidação, deve ser feita a Baixa Gerencial, preenchendo a Data de Crédito no Exterior."###"Atenção"
               lRet:=.f.
               Break
            EndIf
         ElseIf Empty(M->EEQ_DTCE)
	        EasyHelp(STR0091,STR0007) //"A data de crédito no exterior deve ser informada."###"Atenção"
	        lRet:=.f.
	        Break
         EndIf
      Else
          // ** Valida o numero da operação. // GFP - 05/09/2012
         If !Empty(M->EEQ_PGT) .AND. Empty(M->EEQ_NROP)
            EasyHelp(STR0066,STR0007) //"Número da operação deve ser informado."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida a moeda da operação.    // GFP - 05/09/2012
         If Empty(M->EEQ_MOEDA)
            EasyHelp(STR0090,STR0007) //"A moeda deve ser informada."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // ** Valida o codigo do banco.     // GFP - 05/09/2012
         If !Empty(M->EEQ_PGT) .AND. If(lAdtMovExt .And. EasyVerModal('M'),Empty(M->EEQ_BCOEXT),Empty(M->EEQ_BANC))  //NCF - 01/10/2015 - Adiant. com Mov. Exterior
            EasyHelp(STR0067,STR0007) //"O banco utilizado para fechamento de câmbio deve ser informado."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         // Valida data de credito no exterior   // GFP - 05/09/2012
         If If(lAdtMovExt .And. EasyVerModal('M') .and. nOpcAdClPd == 5,.F.,Empty(M->EEQ_DTCE))       //NCF - 01/10/2015 - Adiant. com Mov. Exterior
            EasyHelp(STR0091,STR0007) //"A data de crédito no exterior deve ser informada."###"Atenção"
            lRet:=.f.
            Break
         EndIf
      EndIf

   Elseif nTipo == EXC_DET

      If lEEQAuto .Or. MsgYesNo(STR0042,STR0040) //"Confirma exclusão do Registro Atual ?"###"Aviso"

         Work_Pgto->(DbGoTo(nReg))

         If Work_Pgto->RECNO != 0
            aAdd(aDeletados,Work_Pgto->RECNO)
         EndIf
        
         //Work_Pgto->DELETE := .T.
         Work_Pgto->(DbDelete())
         Work_Pgto->(DbGoTop())
      Else
         lRet := .F.
         Break
      EndIf
   ElseIf nTipo == BXG_DET
      SA6->(DbSetOrder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON
      If !(lRet := SA6->(DbSeek(xFilial()+M->(EEQ_BCOEXT+EEQ_AGCEXT+EEQ_CNTEXT))))
         EasyHelp(STR0101 + ENTER + STR0102, STR0016)//"A conta informada não existe no cadastro de bancos."### "Escolha uma conta válida." ###"Aviso"
         Break
      EndIf
      If IsBancoExt(M->EEQ_BCOEXT, M->EEQ_AGCEXT, M->EEQ_CNTEXT) .AND. !(lRet := SA6->A6_MOEEASY == M->EEQ_MOEDA)
         EasyHelp(STR0104 + ENTER + STR0105, STR0007)//"A moeda da conta escolhida é diferente da moeda da parcela."###"Escolha uma conta na mesma moeda da parcela."###"Atenção"
         Break
      EndIf
   EndIf

   IF EasyEntryPoint("EECAC100") // ** JPM - ponto de entrada na validação da alteração da parcela.
      Private lRetPonto := lRet

      ExecBlock("EECAC100",.F.,.F.,"VALIDA_MANUT_PARC")

      If ValType(lRetPonto) = "L"
         lRet := lRetPonto
      EndIf
   Endif
End Sequence

Return lRet

/*
Funcao      : GravaAdian().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Gravar Adiantamentos do Cliente.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/11/2002 - 11:14.
Revisao     :
Obs.        :
*/
*--------------------------*
STATIC Function GravaAdian()
*--------------------------*
Local lRet := .t.
Local j:= 0
Local i:= 0
Local cOldFilial := ""
Local lAlteraAdi := .F.
Local aCposInt:= {"EEQ_NRINVO","EEQ_VL","EEQ_DTCE","EEQ_PGT","EEQ_NROP","EEQ_TX","EEQ_BANC","EEQ_AGEN","EEQ_NCON","EEQ_VCT"}
Local lAltTit:= .F.
Local lEliminaSld := .F., lEstEliSld := .F.
Local lGerou := lBaixou := .F.   // GFP - 31/08/2012
Private cSeek:= 'SE1->(DbSeek(xFilial()+"EEC"+AvKey(EEQ->EEQ_FINNUM, "E1_NUM")+AvKey(" ", "E1_PARCELA")+AvKey(TETpTitEEQ("EEQ"),"E1_TIPO")))'   //NCF - 04/07/2019
Private aTMPAlt := {}

If Type("lRollBack") <> "L"
   lRollBack := .F.
EndIf

Begin Sequence

   ProcRegua(Work_Pgto->(EasyRecCount("Work_Pgto"))+1)
   IncProc(STR0043) //"Atualizando arquivos ..."

   For j:=1 To Len(aDeletados)
      IncProc()
      EEQ->(DbGoTo(aDeletados[j]))
      // MPG - 10/07/2018 - Estornar ação de exclusão quando a integração com Logix retornar erro
        aReg := {}
        FOR i:=1 To EEQ->(Fcount())
            aAdd(aReg, &("EEQ->"+EEQ->(FIELDNAME(i)) ) )
        Next i
        aAdd( aRetEEQ , {aDeletados[j],aClone(aReg)} )
      //RMD - 10/11/07 - Nova Legislação Câmbio
      //Exclui as movimentações
      If EECFlags("CAMBIO_EXT")
         AD101GrvInv("EEQ", "EEQ", "EXPBXG", .T.)
         AD101GrvInv("EEQ", "EEQ", "EXPLIQ", .T.)
      EndIf
      EEQ->(RecLock("EEQ",.f.))
      //RMD - 02/02/07 - Integração com o SIGAFIN e SIGACTB
      //If IsIntEnable("001")
         If !Empty(EEQ->EEQ_FINNUM)
            lRet:= AvStAction("002")//Estorno de título de adiantamento no SIGAFIN
            If !lRet //DFS - 16/05/12 - Inclusão de tratamento para não salvar a estorno do adiantamento se não for incluso anteriormente no Financeiro
               lRollBack := .T.
            EndIf
         EndIf
      //EndIf
      EEQ->(DbDelete())
      EEQ->(MSUnlock())
      If lRollBack //DFS - 16/05/12 - Se for .T., sai da função.
         Exit
      EndIf
   Next

   //NCF - 03/11/2014
   If AVFLAGS("EEC_LOGIX")
      Work_Pgto->(DBGOTOP())
      DO WHILE !Work_Pgto->(EOF()) .And. !lRollBack
         aReg := {}
         FOR i:=1 To Work_Pgto->(Fcount())
            aAdd(aReg, &("Work_Pgto->"+Work_Pgto->(FIELDNAME(i)) ) )
         Next i
         aAdd(aTMPAlt, aReg)
         Work_Pgto->(DbSkip())
      ENDDO
      ASORT(aTMPAlt,,, {|x,y| VAL( x[ Work_Pgto->(FieldPos("EEQ_FINNUM")) ]) > VAL(y[ Work_Pgto->(FieldPos("EEQ_FINNUM")) ])   .And.  x[ Work_Pgto->(FieldPos("EEQ_VCT")) ] > y[ Work_Pgto->(FieldPos("EEQ_VCT")) ]    } )
   EndIf

   Work_Pgto->(dbGoTop())

   Do While Work_Pgto->(!Eof()) .And. (AvFlags("EEC_LOGIX") .Or. !lRollBack)
      IncProc()
   
      lEstEliSld := .F. //FDR - 28/12/2016
      lEliminaSld := .F. //AAF 04/01/2016
      
      If Work_Pgto->RECNO == 0

         IF EasyEntryPoint("EECAC100") // ** JPM - Ponto de entrada na inclusão de parcela
            ExecBlock("EECAC100",.F.,.F.,"INCLUINDO_EEQ")
         Endif

         //RMD - 10/11/07 - Nova Legislação Câmbio
         If EECFlags("CAMBIO_EXT")
            //Grava as movimentações
            AD101GrvInv("EEQ", "Work_Pgto", "EXPBXG",, Work_Pgto->RECNO <> 0)
            AD101GrvInv("EEQ", "Work_Pgto", "EXPLIQ",, Work_Pgto->RECNO <> 0)
         EndIf

         EEQ->(RecLock("EEQ",.t.))
         EEQ->EEQ_FILIAL := xFilial("EEQ")
         AvReplace("Work_Pgto","EEQ")
         //EEQ->EEQ_EVENT := "605"   //NCF - 02/07/2019 - Assumir o que foi gravado no registro
         EEQ->EEQ_EMISSA := dDataBase  //NCF - 07/06/2021

         // BAK - Tratamento para salvar o campo EEQ_VCT e EEQ_HVCT
         If EEQ->(FieldPos("EEQ_VCT")) > 0 .And. EEQ->(FieldPos("EEQ_HVCT")) > 0
            If !Empty(EEQ->EEQ_PGT)
               EEQ->EEQ_VCT := EEQ->EEQ_PGT //LRS - 23/09/2015
            Else
               EEQ->EEQ_VCT := dDataBase
            EndIf
            EEQ->EEQ_HVCT := EEQ->EEQ_VCT
         EndIf

         If EECFlags("FRESEGCOM")
            EEQ->EEQ_MOEDA  := Work_Pgto->EEQ_MOEDA //Posicione("EXJ",1,xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA,"EXJ_MOEDA") // SA1->A1_MOEDA  - By JPP - 01/03/2005 12:00 - O campo A1_MOEDA não existe mais e passou a ser o campo EXJ_MOEDA   //GFP - 23/08/2012 - Preenche com Moeda da Work
            EEQ->EEQ_IMPORT := SA1->A1_COD
            EEQ->EEQ_IMLOJA := SA1->A1_LOJA
         EndIf

         If Select("SYF") == 0  // GFP - 25/09/2014
            //ChkFile("SYF",.T.) LRS-27/06/2017
         EndIf
         SYF->(DbSetOrder(1))   // GFP - 26/09/2014
         SYF->(DbSeek(xFilial("SYF")+EEQ->EEQ_MOEDA))
         //RMD - 02/02/07 - Integração com o SIGAFIN e SIGACTB
         //WFS - 10/03/09 - Para gerar um novo título no financeiro, o adiantamento deve ter saldo
         //If !Empty(EEQ->EEQ_PGT) .And. Empty(EEQ->EEQ_FAOR)
         //If IsIntEnable("001")
            If !Empty(EEQ->EEQ_PGT) .And. Empty(EEQ->EEQ_FAOR) .And. EEQ->EEQ_SALDO > 0
               lRet:= AvStAction("001")//Inclusão de título de adiantamento no SIGAFIN
               //DFS - 16/05/12 - Inclusão de tratamento para não salvar a inclusão do adiantamento se não for incluso no Financeiro
               If !lRet
                  lRollBack := .T.
               EndIf

               //FSM - 08/10/2012
               If lRet .And. lFinanciamento .And. lIntFina
                  EasyLiqContAdian()
               EndIf
            EndIf
         //EndIf

      Else
         EEQ->(dbGoTo(Work_Pgto->RECNO))

        // MPG - 10/07/2018 - Estornar ação de exclusão quando a integração com Logix retornar erro
        aReg := {}
        FOR i:=1 To EEQ->(Fcount())
            aAdd(aReg, &("EEQ->"+EEQ->(FIELDNAME(i)) ) )
        Next i
        aAdd( aRetEEQ , {Work_Pgto->RECNO,aClone(aReg)} )

         lAltTit:= AvGeraTit("Work_Pgto", "EEQ", aCposInt) //Verifica se houve alteração que implica na recriação dos títulos no financeiro (sigafin)

         IF EasyEntryPoint("EECAC100") // ** JPM - Ponto de entrada na alteração de parcela, para que se possa saber o que foi alterado.
            ExecBlock("EECAC100",.F.,.F.,"ALTERANDO_EEQ")
         Endif
         //RMD - 10/11/07 - Nova Legislação Câmbio
         If EECFlags("CAMBIO_EXT")
            //Grava as movimentações
            AD101GrvInv("EEQ", "Work_Pgto", "EXPBXG",, Work_Pgto->RECNO <> 0)
            AD101GrvInv("EEQ", "Work_Pgto", "EXPLIQ",, Work_Pgto->RECNO <> 0)
         EndIf

         If EEQ->(FieldPos("EEQ_SLDELI")) > 0
         	//RMD - 11/05/12 - Baixa o saldo eliminado no financeiro
            If !Empty(Work_Pgto->EEQ_SLDELI) .And. Empty(EEQ->EEQ_SLDELI)
               lEliminaSld := .T.
            EndIf
            If Empty(Work_Pgto->EEQ_SLDELI) .And. !Empty(EEQ->EEQ_SLDELI)
               lEstEliSld := .T.
            EndIf
         EndIf

         cOldFilial := EEQ->EEQ_FILIAL
         EEQ->(RecLock("EEQ",.f.))
         AvReplace("Work_Pgto","EEQ")
         //EEQ->EEQ_EVENT := "605"    //NCF - 02/07/2019 - Assumir o que foi gravado no registro
         EEQ->EEQ_FILIAL := cOldFilial

         // BAK - Tratamento para salvar o campo EEQ_VCT e EEQ_HVCT
         If EEQ->(FieldPos("EEQ_VCT")) > 0 .And. EEQ->(FieldPos("EEQ_HVCT")) > 0
            If !Empty(EEQ->EEQ_PGT)
               EEQ->EEQ_VCT := EEQ->EEQ_PGT //LRS - 23/09/2015
            EndIf
         EndIf

         //RMD - 02/02/07 - Integração com o SIGAFIN e SIGACTB
         //If IsIntEnable("001")
            If Empty(EEQ->EEQ_PGT)
               If !Empty(EEQ->EEQ_FINNUM)

                  //NCF - 15/05/2015 - Verificar estorno automático da liquidação do adiantamento
                  If AvFlags("EEC_LOGIX") .and. !Empty(EEQ->EEQ_SEQBX)
                     lRet := AvStAction("009")
                     If !lRet
                        lRollBack := .T.
                     Else
                        lAF212EsBxAuto := .T.
                     EndIf
                  EndIf

                  lRet:= AvStAction("002")//Estorno de título de adiantamento no SIGAFIN
                  If !lRet //DFS - 16/05/12 - Inclusão de tratamento para não salvar o estorno do adiantamento se não for incluso no Financeiro
                     lRollBack := .T.
                  EndIf

                  //NCF - 15/05/2015
                  lAF212EsBxAuto := .F.

                  //FSM - 08/10/2012
                  If lRet .And. lFinanciamento .And. lIntFina
                     EasyEstLiqContAdian()
                  EndIf
               EndIf
            ElseIf Empty(EEQ->EEQ_FAOR)
               //WFS - 10/03/09 - Para gerar um novo título no financeiro, o adiantamento deve ter saldo
               //If Empty(EEQ->EEQ_FINNUM)
               If Empty(EEQ->EEQ_FINNUM) .And. EEQ->EEQ_SALDO > 0
                  lRet:= AvStAction("001")//Inclusão de título de adiantamento no SIGAFIN
                  lGerou := lRet   // GFP - 03/09/2012
                  If !lRet  //DFS - 16/05/12 - Inclusão de tratamento para não salvar a inclusão do adiantamento se não for incluso no Financeiro
                     lRollBack := .T.
                  EndIf

                  //FSM - 08/10/2012
                  If lRet .And. lFinanciamento .And. lIntFina
                     EasyLiqContAdian()
                  EndIf

               //WFS - 10/03/09 - Para gerar um novo título no financeiro, o adiantamento deve ter saldo
               //Else
               ElseIf EEQ->EEQ_SALDO > 0 .AND. !Empty(EEQ->EEQ_FINNUM) .And. lAltTit //WFS 10/03/09
                  lRet:= AvStAction("003")//Alteração de título de adiantamento no SIGAFIN
                  If !lRet  //DFS - 16/05/12 - Inclusão de tratamento para não salvar a alteração do adiantamento se não for incluso no Financeiro
                     lRollBack := .T.
                  EndIf

  /*               //FSM - 08/10/2012
                  If lRet .And. lFinanciamento .And. lIntFina
                     EasyLiqContAdian()
                  EndIf*/

               ElseIf lEliminaSld .Or. lEstEliSld
                  IF !Empty(EEQ->EEQ_FINNUM) .And. (&cSeek)
                     If lEstEliSld
                        SE5->(DbSetOrder(7))
                        If lRet := SE5->(DbSeek(xFilial()+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
                           nParcEst := 1
                           lRet := AvStAction("009")//Estorno de Baixa de Titulo a Receber
                           If !lRet //DFS - 16/05/12 - Inclusão de tratamento para não salvar a baixa do titulo a receber se não for incluso anteriormente no Financeiro
                              lRollBack := .T.
                           EndIf
                        EndIf
                     Else
                        If !Empty(EEQ->EEQ_PGT)
                           if EasyVerModal() .AND. !Empty(EEQ->EEQ_DTCE)
                              nValorBaixa := EEQ->EEQ_SLDELI
                           else
                              nValorBaixa:= Round(EEQ->EEQ_SLDELI * EEQ->EEQ_TX,AvSx3("EEQ_EQVL", AV_DECIMAL))//EEQ->EEQ_EQVL
                           endif
                           //AAF 04/10/2017 - Utilizar a database e não a data da liquidacao para eliminação de saldo. (problema com movimento no SE5 e MV_DATAFIN)
						         dDtBaixa := dDataBase //EEQ->EEQ_PGT
                           lRet := AvStAction("008")//Baixa de Titulo a Receber
                           If !lRet //DFS - 16/05/12 - Inclusão de tratamento para não salvar a baixa do titulo a receber se não for incluso anteriormente no Financeiro
                              lRollBack := .T.
                           EndIf
                        EndIf
                     EndIf
                  EndIf
               EndIf
            EndIf
      EndIf

      IF EasyEntryPoint("EECAC100") // By JPP - 26/04/2006 - 13:39 - Inclusão do Ponto de Entrada
         ExecBlock("EECAC100",.F.,.F.,"GRAVANDO_EEQ")
      Endif

      //RMD - 25/11/08 - Todas as parcelas geradas pela exportação devem conter o identificador "1 - Cambio de Exportação" no campo EEQ_TP_CON
      If lRollBack
         Exit
      Else
          If EEQ->(FieldPos("EEQ_TP_CON")) > 0
            EEQ->EEQ_TP_CON := "1"
         EndIf
         EEQ->(MSUnlock())
      EndIf

      Work_Pgto->(DbSkip())
   EndDo

   If lRollBack .And. !AvFlags("EEC_LOGIX") //DFS - 16/05/12 - Mensagem impeditiva, a variavel logica for .T.
      ELinkRollBackTran()
      //RollBackDelTran("")
   EndIf

   IF EasyEntryPoint("EECAC100")  // By JPP - 26/04/2006 - 13:39 - Inclusão do Ponto de Entrada
      ExecBlock("EECAC100",.F.,.F.,"ANTES_DELETAR_EEQ")
   Endif

End Sequence

Return lRet

/*
Funcao      : AC100AtuSld().
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Calcular o saldo total dos adiantamentos do cliente.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/11/02 16:54.
Obs.        :
*/
*---------------------------*
Static Function AC100AtuSld()
*---------------------------*
Local lRet:= .t., nRec := Work_Pgto->(RecNo())

Begin Sequence

   nSaldo:=0
   Work_Pgto->(DbGoTop())

   Do While Work_Pgto->(!Eof())
      nSaldo += Work_Pgto->EEQ_SALDO // ** Acumula o Saldo.
      Work_Pgto->(DbSkip())
   EndDo

End Sequence

Work_Pgto->(DbGoTo(nRec))

Return lRet

/*
Funcao      : CalcParc().
Parametros  : Nenhum.
Retorno     : nParc => Nro da proxima parcela.
Objetivos   : Calcular próximo nro da parcela.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/11/02 16:54.
Obs.        :
*/
*------------------------*
Static Function CalcParc(cEEQ_PREEMB, cEEQ_FASE)
*------------------------*
Local cParc, nRec:=Work_Pgto->(RecNo())
Local aParc:={}
Local cMaxParcbase := Replicate("0",AvSX3("EEQ_PARC",AV_TAMANHO))
Local cQry //AAF 06/01/2017 - Considerar a parcela de todas as filiais. Parcela precisa ser unica para nao dar problema com multifiliais.

Begin Sequence

   If Select("QRYAC100") > 0
      QRYAC100->(dbCloseArea())
   EndIf

   cQry := "Select max(EEQ_PARC) as MAIOR from " + RetSqlName("EEQ") + " where EEQ_PREEMB = '"+cEEQ_PREEMB+"' and EEQ_FASE = '"+cEEQ_FASE+"' "
   dbUseArea(.T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQry)), "QRYAC100", .F., .T.)   
   
   cMaxParcbase := QRYAC100->MAIOR

   QRYAC100->(dbCloseArea())
   
   Work_Pgto->(DbGoTop())
   Do While Work_Pgto->(!Eof())
      aAdd(aParc,Work_Pgto->EEQ_PARC)
      Work_Pgto->(DbSkip())
   EndDo

   aSort(aParc,,,{|x,y| x > y })

   If Len(aParc) > 0
      cParc := aParc[1]
   Else
      cParc := Replicate("0",AvSX3("EEQ_PARC",AV_TAMANHO))
   EndIf

   cParc := If(cMaxParcbase > cParc,cMaxParcbase,cParc)
   
   //RMD - Gravar letras na sequência visto que o campo possui tamanho 2
   cParc := SomaIt(cParc)

End Sequence

Work_Pgto->(DbGoTo(nRec))

Return cParc

/*
Funcao      : AC100ViewHist().
Parametros  : Nenhum.
Retorno     : .T.
Objetivos   : Vizualização do histórico do adiantamento.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/11/02 10:22.
Obs.        :
*/
*-----------------------------*
Static Function AC100ViewHist()
*-----------------------------*
Local aOrd:=SaveOrd("EEQ"), aPos:={}, aHist_PedEmb:={},aHist_Emb:={}, aAux:={}
Local bOk:={|| oDlg:End()}, bCancel:={|| oDlg:End()}
Local cDesc, cTit := STR0044 //"Histórico."
Local nValAdian := 0, i:=0
Local dDtAdian  := AvCtod("")
Local oTree, oDlg, oPanel1, oPanel2
Local lRet:=.t.
Local aFil := {}, cFil := ""

Begin Sequence

   //ER - 20/06/2006 às 10:30
   If Work_Pgto->(EOF()) .or. Work_Pgto->(BOF())
      HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
      Break
   EndIf

   If Work_Pgto->EEQ_SALDO == Work_Pgto->EEQ_VL
      MsgInfo(STR0080,STR0040)//"Não existe histórico para esse item."###"Aviso"
      Break
   EndIf

   EEQ->(DbSetOrder(7))

   /*
   // ** Faz a leitura dos processos que utilizaram o adiantamento solicitado para a fase de pedido e embarque.
   If !EEQ->(DbSeek(xFilial("EEQ")+"C"+Work_Pgto->EEQ_PREEMB+Work_Pgto->EEQ_PARC))
      Break
   EndIf
   */

   cFil := xFilial("EEQ")

   //ER - 29/06/2007 - Quando a tabela EEQ for corpatilhada, o cFil será igual à "  ".
   If Empty(cFil)
      aAdd(aFil,cFil)
   Else
      //Seleciona todas as Filiais
      aFil := AvgSelectFil(.F.)
   EndIf

   For i:=1 to Len(aFil)

      // ** Faz a leitura dos processos que utilizaram o adiantamento solicitado para a fase de pedido e embarque.
      If EEQ->(DbSeek(aFil[i]+"C"+Work_Pgto->EEQ_PREEMB+Work_Pgto->EEQ_PARC))

         Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == aFil[i] .And.;
                                      EEQ->EEQ_FAOR   == "C" .And.;
                                      EEQ->EEQ_PROR   == Work_Pgto->EEQ_PREEMB .And.;
                                      EEQ->EEQ_PAOR   == Work_Pgto->EEQ_PARC
            If EEQ->EEQ_FASE =="P"
               EXJ->(DbSetOrder(1))
               EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))

               cDesc := STR0050+AllTrim(EEQ->EEQ_PREEMB)+STR0051+AllTrim(EXJ->EXJ_MOEDA)+Space(2)+; //"Processo: "###" - Valor: "
                        AllTrim(Transf(EEQ->EEQ_VL,AVSX3("EEQ_VL",AV_PICTURE)))

               If aScan(aAux,{|aX| aX[1]=EEQ->EEQ_PREEMB}) = 0
                  aAdd(aAux,{EEQ->EEQ_PREEMB,cDesc})
               EndIf
            EndIf

            EEQ->(DbSkip())
         EndDo
      EndIf
   Next

   // ** Faz a leitura dos lançamentos de cambio que utilizaram o adiantamento selecionado.
   For i:=1 To Len(aAux)
      If EEQ->(DbSeek(xFilial("EEQ")+"P"+aAux[i][1]+Work_Pgto->EEQ_PARC))
         aAdd(aHist_PedEmb,{aAux[i][2],{}})

         Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == xFilial("EEQ") .And.;
                                      EEQ->EEQ_FAOR   == "P" .And.;
                                      EEQ->EEQ_PROR   == aAux[i][1] .And.;
                                      EEQ->EEQ_PAOR   == Work_Pgto->EEQ_PARC
            If EEQ->EEQ_FASE =="E"
               EXJ->(DbSetOrder(1))
               EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))

               cDesc := STR0052+AllTrim(EEQ->EEQ_PREEMB)+STR0051+AllTrim(EXJ->EXJ_MOEDA)+Space(2)+; //"Cambio/Embarque: "###" - Valor: "
                        AllTrim(Transf(EEQ->EEQ_VL,AVSX3("EEQ_VL",AV_PICTURE)))

               aAdd(aHist_PedEmb[i][2],cDesc)
            EndIf

            EEQ->(DbSkip())
         EndDo
      Else
         aAdd(aHist_PedEmb,{aAux[i][2]})
      EndIf
   Next

   For i:=1 to Len(aFil)
      // ** Faz a leitura dos processos que utilizaram o adiantamento apenas na fase de embarque.
      If EEQ->(DbSeek(aFil[i]+"C"+Work_Pgto->EEQ_PREEMB+Work_Pgto->EEQ_PARC))

         Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == aFil[i] .And.;
                                   EEQ->EEQ_FAOR   == "C" .And.;
                                   EEQ->EEQ_PROR   == Work_Pgto->EEQ_PREEMB .And.;
                                   EEQ->EEQ_PAOR   == Work_Pgto->EEQ_PARC
            If EEQ->EEQ_FASE =="E"
               EXJ->(DbSetOrder(1))
               EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))

               cDesc := STR0052+AllTrim(EEQ->EEQ_PREEMB)+STR0051+AllTrim(EXJ->EXJ_MOEDA)+Space(2)+; //"Cambio/Embarque: "###" - Valor: "
                        AllTrim(Transf(EEQ->EEQ_VL,AVSX3("EEQ_VL",AV_PICTURE)))
               aAdd(aHist_Emb,cDesc)
            EndIf
            EEQ->(DbSkip())
         EndDo
      EndIf
   Next
   // ** By JBJ - 15/03/04 - Visualizar a Dt.Pagto.
   dDtAdian  := Work_Pgto->EEQ_DTCE // Work_Pgto->EEQ_VCT
   nValAdian := Work_Pgto->EEQ_VL

   DEFINE MSDIALOG oDlg TITLE cTit FROM 9,0 TO 35,80 OF oMainWnd

      aPos := PosDlg(oDlg)

      oPanel1:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, aPos[4], aPos[3]*0.17)
      oPanel2:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, aPos[4], aPos[3]*0.75)

      @ 02,02 TO aPos[3]*0.17, aPos[4]-1 LABEL STR0055 Pixel Of oPanel1  //"Detalhes do Adiantamento"

      @ 15,007 Say STR0053  Size 65,07 Pixel Of oPanel1 //"Data"
      @ 15,080 Say STR0028  Size 65,07 Pixel Of oPanel1 //"Valor"
      @ 15,165 Say STR0029  Size 65,07 Pixel Of oPanel1 //"Saldo"

      @ 14,030 MSGET dDtAdian  PICTURE AVSX3("EEQ_VCT",AV_PICTURE) Size 040,07 Pixel Of oPanel1 When .f.
      @ 14,105 MSGET nValAdian PICTURE AVSX3("EEQ_VL",AV_PICTURE)  Size 055,07 Pixel Of oPanel1 When .f.
      @ 14,185 MSGET Work_Pgto->EEQ_SALDO PICTURE AVSX3("EEQ_VL",AV_PICTURE)  Size 055,07 Pixel Of oPanel1 When .f.

      oTree := DbTree():New(002,002,aPos[3]*0.74,aPos[4]-1,oPanel2,,,.T.)

      // ** Efetua a leitura de todos os itens para montagem do tree.
      AC100ReadTree(oTree,aHist_PedEmb,aHist_Emb)

      // WFS - alinhamento de tela
      oPanel1:Align:= CONTROL_ALIGN_TOP
      oPanel2:Align:= CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AC100ReadTree(oTree,aHist_PedEmb,aHist_PedEmb).
Parametros  : oTree        => Objeto.
              aHist_PedEmb => Array com os adiantamentos que possuem pedido.
              aHist_Emb    => Array com os adiantamentos que nao possuem pedido mas possuem embarque.
Retorno     : .T.
Objetivos   : Carrega o tree com os dados do historico do adiantamento selecionado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 05/11/02 12:22.
Obs.        :
*/
*---------------------------------------------------------*
Static Function AC100ReadTree(oTree,aHist_PedEmb,aHist_Emb)
*---------------------------------------------------------*
Local lRet := .t., i:=0, j:=0

Begin Sequence

   DBADDTREE oTree PROMPT STR0045+Space(60) OPENED RESOURCE 'BMPCONS' CARGO "L" //"Histórico do Adiantamento."

   For i:=1 To Len(aHist_PedEmb)
      // ** Adiciona um processo ...
      DBADDTREE oTree PROMPT AllTrim(aHist_PedEmb[i][1]) OPENED RESOURCE 'PMSDOC' CARGO "P"

      If Len(aHist_PedEmb[i]) > 1
         If ValType(aHist_PedEmb[i][2])="A"
            For j:=1 To Len(aHist_PedEmb[i][2]) // ** Adiciona Cambio/Embarques...
               If ValType(aHist_PedEmb[i][2][j])="C"
                  DBADDITEM oTree PROMPT AllTrim(aHist_PedEmb[i][2][j]) RESOURCE 'RELATORIO' CARGO "E"
               EndIf
            Next
            DBENDTREE oTree
         EndIf
      Else
         DBENDTREE oTree
      EndIf
   Next

   If Len(aHist_Emb) > 0
      For i:=1 To Len(aHist_Emb)
         If ValType(aHist_Emb[i])="C"
            DBADDITEM oTree PROMPT AllTrim(aHist_Emb[i]) RESOURCE 'RELATORIO' CARGO "E"
         EndIf
      Next
   EndIf

   DBENDTREE oTree

   oTree:Refresh()
   oTree:SetFocus()

End Sequence

Return lRet
*--------------------------------------------------------------------
/*
Funcao....: AC100CLPR()
Parametro.: 1.nP_OPC -> NUMERO DA OPCAO DO MBROWSE
Objetivos.: RELACIONAR OS PRODUTOS COM O CLIENTE
Autor.....: LUCIANO CAMPOS DE SANTANA
Data/Hora.: 29/01/03 15:52
Obs.......: ESTE BOTAO SO SERA HABILITADO SE O EXH ESTIVER NO SIGAEEC.MNU
*/
STATIC FUNCTION AC100CLPR(nP_OPC)
LOCAL bOK,bCANCEL,nBTOP,oDLG,oMSELECT,aMSCPOS,aPOS,aORD,cTITULO,lBAVAL
LOCAL oPanel
PRIVATE aBUTTONS

BEGIN SEQUENCE
   aMSCPOS  := {COLBRW("EXH_COD_I","TEXH"),;
                {{|| TEXH->TEXH_DESCR},"",STR0056}} //"Descrição do Produto"
   aORD     := SAVEORD({"SYA"})
   aBUTTONS := {}
   bOK      := {|| nBTOP := 1,oDLG:END()}
   bCANCEL  := {|| nBTOP := 0,oDLG:END()}
   nBTOP    := 0
   cTITULO  := cCADASTRO+STR0057 //" - Cliente X Produtos"
   lBAVAL   := "V"
   If FWModeAccess("SA1",3) <> FWModeAccess("EXH",3)
      EasyHelp(STR0107,STR0040) //"O modo de compartilhamento entre as tabelas de Clientes (SA1) e Clientes x Produtos (EXH) estão diferentes. Para o uso desta rotina, o modo de compartilhamento entre estas tabelas devem ser iguais."###"Aviso"
      Break
   EndIf
   // LOCALIZA O PAIS DO CLIENTE
   SYA->(DBSETORDER(1))
   SYA->(DBSEEK(XFILIAL("SYA")+M->A1_PAIS))
   // CARREGA OS BOTOES
   IF nP_OPC = INCLUIR .OR. nP_OPC = ALTERAR
      IF nP_OPC = INCLUIR .AND. (EMPTY(M->A1_COD) .OR. EMPTY(M->A1_LOJA))
         MSGINFO(STR0058,STR0007) //"Preencha primeiro o código e a loja do Cliente !"###"Atenção"
         BREAK
      ENDIF
      AADD(aBUTTONS,{"BMPINCLUIR" /*"EDIT"*/,     {|| AC100IAEV("I",cTITULO)},STR0003}) //"Incluir"
      AADD(aBUTTONS,{"EDIT" /*"ALT_CAD"*/,  {|| AC100IAEV("A",cTITULO)},STR0004}) //"Alterar"
      AADD(aBUTTONS,{"EXCLUIR",  {|| AC100IAEV("E",cTITULO),oMSELECT:oBROWSE:REFRESH()},STR0005}) //"Excluir"
      lBAVAL := "A"
   ELSE
      AADD(aBUTTONS,{"RELATORIO" /*"ANALITICO"*/,{|| AC100IAEV("V",cTITULO)},STR0002}) //"Visualizar"
   ENDIF
   TEXH->(DBGOTOP())

   // DFS - Criação de ponto de entrada para tratemento de variáveis e botões
   IF(EasyEntryPoint("EECAC100"),Execblock("EECAC100",.F.,.F.,"ATUALIZA_BOTOES"),)

   DEFINE MSDIALOG oDLG TITLE cTITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      @00,00 MSPANEL oPanel PROMPT "" SIZE 30,45 OF oDlg

      @ 15,007 SAY STR0020 SIZE 65,07 PIXEL OF oPanel //"Codigo"
      @ 15,100 SAY STR0021 SIZE 65,07 PIXEL OF oPanel //"Nome"
      *
      @ 15,35  MSGET M->A1_COD  SIZE 040,07 PIXEL OF oPanel WHEN(.F.)
      @ 15,140 MSGET M->A1_NOME SIZE 120,07 PIXEL OF oPanel WHEN(.F.)
      *
      @ 25,007 SAY STR0022 SIZE 40,07 PIXEL OF oPanel //"Pais"
      @ 25,100 SAY STR0023 SIZE 35,07 PIXEL OF oPanel //"Desc.Pais"
      *
      @ 25,35  MSGET M->A1_PAIS      SIZE 040,07 PIXEL OF oPanel WHEN(.F.)
      @ 25,140 MSGET SYA->YA_NOIDIOM SIZE 120,07 PIXEL OF oPanel WHEN(.F.)

      aPOS     := POSDLGDOWN(oDLG)
      aPOS[1]  := 36
      oMSELECT := MSSELECT():NEW("TEXH",,,aMSCPOS,@lINVERTE,@cMARCA,aPOS)
      oMSELECT:BAVAL := {|| AC100IAEV(lBAVAL,cTITULO)}
      oPanel:Align := CONTROL_ALIGN_TOP
	  oMSELECT:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
   oDlg:lMaximized:=.T. //Maximiliza Janela  
   ACTIVATE MSDIALOG oDLG ON INIT (ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS))
END SEQUENCE
RESTORD(aORD)
RETURN(NIL)
*--------------------------------------------------------------------
/*
Funcao....: AC100IAEV()
Parametro.: 1.cP_MODO   -> BOTAO QUE FOI SELECIONADO
            2.cP_TITULO -> TITULO DA JANELA
Objetivos.: RELACIONAR OS PRODUTOS COM O CLIENTE
Autor.....: LUCIANO CAMPOS DE SANTANA
Data/Hora.: 29/01/03 15:52
Obs.......: ESTE BOTAO SO SERA HABILITADO SE O EXH ESTIVER NO SIGAEEC.MNU
*/
STATIC FUNCTION AC100IAEV(cP_MODO,cP_TITULO)
LOCAL oDLG,bOK,bCANCEL,nBTOP,I,aPOS,nOPC
LOCAL oPanel
LOCAL aCpos:= {}
*
PRIVATE aTELA[0,0],aGETS[0],aMEMOS,lCOD,lMEMO
*
BEGIN SEQUENCE
   DBSELECTAREA("TEXH")
   aMEMOS    := {{"EXH_DESC","EXH_VM_DES"}}
   aBUTTONS  := {}
   bOK       := {|| If(Obrigatorio(aGets,aTela),(nBTOP:=1, oDlg:End()),Nil)} //MCF - 25/08/2015
   bCANCEL   := {|| nBTOP := 0,oDLG:END()}
   nBTOP     := 0
   IF cP_MODO = "I"
      TEXH->(DBGOBOTTOM())
      TEXH->(DBSKIP())
      cP_TITULO := cP_TITULO+STR0059 //" - Incluir"
      lCOD      := lMEMO := .T.
      FOR I := 1 TO TEXH->(FCOUNT())
          IF LEFT(TEXH->(FIELDNAME(I)),4) = "EXH_"
             M->&(TEXH->(FIELDNAME(I))) := CRIAVAR(TEXH->(FIELDNAME(I)))
          ENDIF
      NEXT
   ELSE
      IF TEXH->(EOF()) .AND. TEXH->(BOF())
         MSGINFO(STR0060,STR0007) //"Não há dados p/ Visualizar, Alterar ou Excluir !"###"Atenção"
         BREAK
      ENDIF
      FOR I := 1 TO TEXH->(FCOUNT())
          IF LEFT(TEXH->(FIELDNAME(I)),4) = "EXH_"
             M->&(TEXH->(FIELDNAME(I))) := TEXH->(FIELDGET(I))
          ENDIF
      NEXT
      IF cP_MODO = "V"
         cP_TITULO := cP_TITULO+STR0061 //" - Visualizar"
         lCOD := lMEMO := .F.
      ELSEIF cP_MODO = "E"
             cP_TITULO := cP_TITULO+STR0062 //" - Excluir"
             lCOD := lMEMO := .F.
      ELSEIF cP_MODO = "A"
             cP_TITULO := cP_TITULO+STR0063 //" - Alterar"
             lCOD :=  .F.
             lMEMO := .T.
      ENDIF
   ENDIF
   DEFINE MSDIALOG oDlg TITLE cP_TITULO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      @00,00 MSPANEL oPanel PROMPT "" SIZE 30,45 OF oDlg // --- ACSJ - 30/03/2004

      @ 15,007 SAY STR0020 SIZE 65,07 PIXEL OF oPanel //"Codigo"
      @ 15,100 SAY STR0021 SIZE 65,07 PIXEL OF oPanel //"Nome"
      *
      @ 15,35  MSGET M->A1_COD  SIZE 040,07 PIXEL OF oPanel WHEN(.F.)
      @ 15,140 MSGET M->A1_NOME SIZE 120,07 PIXEL OF oPanel WHEN(.F.)
      *
      @ 25,007 SAY STR0022 SIZE 40,07 PIXEL OF oPanel //"Pais"
      @ 25,100 SAY STR0023 SIZE 35,07 PIXEL OF oPanel //"Desc.Pais"
      *
      @ 25,35  MSGET M->A1_PAIS      SIZE 040,07 PIXEL OF oPanel WHEN(.F.)
      @ 25,140 MSGET SYA->YA_NOIDIOM SIZE 120,07 PIXEL OF oPanel WHEN(.F.)

      //22.mai.2009 - - Retirar a visibilidade do campo FILIAL - HFD
      aCpos := AvCposEnc("EXH", Nil, "EXH_FILIAL")

      aPOS     := POSDLGDOWN(oDLG)
      aPOS[1]  := 36
      oEnCh1 := MsmGet():New("EXH",TEXH->(RECNO()),4,,,,aCpos ,aPOS)
      M->EXH_VM_DES := TEXH->EXH_VM_DES
	  oPanel:Align := CONTROL_ALIGN_TOP //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
	  oEnch1:oBox:Align := CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   ACTIVATE MSDIALOG oDLG ON INIT (ENCHOICEBAR(oDLG,bOK,bCANCEL,,aBUTTONS))
   IF nBTOP = 0
      BREAK
   ENDIF
   IF AT(cP_MODO,"IA") <> 0
      IF cP_MODO = "I"
         TEXH->(DBAPPEND())
      ENDIF
      //RMD - 10/12/19 - Possibilita gravar campos de usuário
      AvReplace("M", "TEXH")
      /*
      TEXH->EXH_COD_I  := M->EXH_COD_I
      TEXH->EXH_VM_DES := M->EXH_VM_DES
      */
      TEXH->TEXH_DESCR := MEMOLINE(M->EXH_VM_DES,AVSX3("EXH_VM_DES",AV_TAMANHO),1)
      TEXH->TRB_ALI_WT := "EXH"
      TEXH->TRB_REC_WT := EXH->(Recno())
   ELSEIF cP_MODO = "E"
          IF ! EMPTY(TEXH->TEXH_RECNO)
            AADD(aDELEXH,TEXH->TEXH_RECNO)
          ENDIF
          TEXH->(DBDELETE())
   ENDIF

   //ER - 13/02/2007
   If EasyEntryPoint("EECAC100")
      ExecBlock("EECAC100",.F.,.F.,{"GRAVA_EXH",cP_MODO})
   EndIf

END SEQUENCE
RETURN(NIL)
*--------------------------------------------------------------------
/*
Funcao....: AC100SB1()
Parametro.: 1.cP_CODIGO -> CODIGO DO PRODUTO
Objetivos.: BUSCA A DESCRICAO DO PRODUTO NO IDIOMA
            VERIFICA SE JA TEM O REGISTRO LANCADO NO EXH
Autor.....: LUCIANO CAMPOS DE SANTANA
Data/Hora.: 30/01/03 15:52
RETORNO...: VERDADEIRO OU FALSO
Obs.......: CHAMADA NO X3_VALID DO CAMPO EXH_COD_I
*/
FUNCTION AC100SB1(cP_CODIGO)
LOCAL lRET
Local aSaveOrd := SaveOrd({"TEXH", "SB1", "EE2"})
*
BEGIN SEQUENCE
   lRET := .T.
   // VERIFICA SE O PRODUTO JA FOI LANCADO
   TEXH->(DBSETORDER(1))
   IF (TEXH->(DBSEEK(cP_CODIGO)))
      MSGINFO(STR0064,STR0007) //"Produto já lançado para este cliente !"###"Atenção"
      lRET := .F.
      BREAK
   ENDIF
   SB1->(DBSETORDER(1))
   EE2->(DBSETORDER(1))
   IF SB1->(DBSEEK(XFILIAL("SB1")+AVKEY(M->cP_CODIGO,"B1_COD")))
      IF EE2->(DBSEEK(XFILIAL("EE2")+MC_CPRO+TM_GER+SYA->YA_IDIOMA+AVKEY(SB1->B1_COD,"EE2_COD")))
         M->EXH_VM_DES := MSMM(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX",AV_TAMANHO))
      ELSE
         HELP(" ",1,"AVG0005001") //MSGINFO("Idioma não encontrado, Padrão: Português","Atenção")
         M->EXH_VM_DES := SB1->B1_DESC
      ENDIF
   ENDIF
END SEQUENCE
RestOrd(aSaveOrd, .T.)
RETURN(lRET)
*--------------------------------------------------------------------
FUNCTION BUSCAPROCLI()
LOCAL lRET
*
lRET := .F.
IF ! EMPTY(M->EE7_IMPORT+M->EE7_IMLOJA)
   //ASK 12/01/07-15:16  IF WORKIT->EE8_COD_I <> M->EE8_COD_I
      EXH->(DBSETORDER(1))
      IF (EXH->(DBSEEK(XFILIAL("EXH")+M->EE7_IMPORT+M->EE7_IMLOJA+M->EE8_COD_I)))
         M->EE8_VM_DES := MSMM(EXH->EXH_DESC,AVSX3("EXH_VM_DESC",AV_TAMANHO))
         lRET          := .T.
      ENDIF
   //ENDIF
ENDIF
RETURN(lRET)

/*
*------------------------------------------------*
/ Funcao....: AC100RestOrDel()                   /
/ Parametro.:                                    /
/ Objetivos.: Eliminar/Restaurar Saldo           /
/ Autor.....: Diogo Felipe dos Santos            /
/ Data/Hora.: 26/07/10 - 15:20                   /
/ RETORNO...: Saldo Eliminado ou Restaurado      /
/ Obs.......:                                    /
*------------------------------------------------*
*/

*--------------------------------*
STATIC FUNCTION AC100RestOrDel()
*--------------------------------*
Local oDlg_banco
Local NI
Local nOpc_banco  := 0
Local aDescMotBx  := {}
Local aMotBx      := ReadMotBx()
Local aBanco      := xCxFina() 
Local cXBanco     := aBanco[1] //Work_Pgto->EEQ_BANC
Local cXAgenc     := aBanco[2] //Work_Pgto->EEQ_AGEN
Local cXConta     := aBanco[3] //Work_Pgto->EEQ_NCON
Local cXMotBx     := ""
Local bOk_banco   := {|| iif(!valid_banco(cXBanco,cXAgenc,cXConta,cXMotBx) , nOpc_banco := 1 ,  ) , iif( nOpc_banco == 1 , oDlg_banco:End() ,  ) }
Local bCn_banco   := {|| oDlg_banco:End() }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o Array aDescMotbx contendo apenas a descricao do	³
//³ motivo das Baixas. 						  								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If len( aDescMotbx ) ==0                           
	For NI := 1 to Len(aMotBx)
		If Substr(aMotBx[nI],34,01) == "A" .or. Substr(aMotBx[nI],34,01) =="R"
			AADD( aDescMotbx,Substr(aMotBx[nI],07,10))
		EndIf
	Next
EndIf

Begin sequence

   If Empty(Work_Pgto->EEQ_FAOR) .AND. !Empty(Work_Pgto->EEQ_SALDO)
      //If MSGYESNO(STR0083) //"Confirma Eliminação de Saldo?"

      nLargura := 236
      nAltura := 260

      DEFINE DIALOG oDlg_banco TITLE "Adiantamentos" FROM 1,1 TO nAltura,nLargura PIXEL

         //@ nLinha, nColuna SAY cTexto SIZE nLargura,nAltura UNIDADE OF oObjetoRef
         //@ nLinha, nColuna MSGET VARIAVEL SIZE nLargura,nAltura UNIDADE OF oObjetoRef F3 cF3 VALID validação WHEN condição PICTURE cPicture
         nLin := 35
         nCol := 08
         @ nLin, nCol SAY "Informe o banco e o motivo de baixa a ser utilizado na baixa do saldo." SIZE 110,20 PIXEL OF oDlg_banco

         nCol := 15
         nLin += 25
         @ nLin, nCol SAY "Banco:" SIZE 50,10 PIXEL OF oDlg_banco
         nCol += 30
         @ nLin-2, nCol MSGET oBanco VAR cXBanco F3 "SA6" PICTURE "@!" SIZE 50, 10 OF oDlg_banco PIXEL HASBUTTON

         nLin += 15
         nCol -= 30
         @ nLin, nCol SAY "Agência:" SIZE 50,10 PIXEL OF oDlg_banco
         nCol += 30
         @ nLin-2, nCol MSGET oAgen VAR cXAgenc PICTURE "@!" WHEN .F. SIZE 50, 10 OF oDlg_banco PIXEL HASBUTTON
         
         nLin += 15
         nCol -= 30
         @ nLin, nCol SAY "Conta:" SIZE 50,10 PIXEL OF oDlg_banco
         nCol += 30
         @ nLin-2, nCol MSGET oNcon VAR cXConta PICTURE "@!" WHEN .F. SIZE 50, 10 OF oDlg_banco PIXEL HASBUTTON

         nLin += 15
         nCol -= 30
         @ nLin, nCol SAY "Mot. Baixa:" SIZE 50,10 PIXEL OF oDlg_banco
         nCol += 30
         @ nLin-1, nCol MSCOMBOBOX oMotBX VAR cXMotBx ITEMS aDescMotBx SIZE 50, 10 OF oDlg_banco PIXEL

      ACTIVATE DIALOG oDlg_banco ON INIT (EnchoiceBar(oDlg_banco, bOk_banco , bCn_banco ,,,,,.F.,.F.,.F.,.T.,.F. )) CENTERED

      if nOpc_banco == 1 .and. MSGYESNO(STR0083)
         cBanco      := cXBanco
         cAgencia    := cXAgenc
         cConta      := cXConta
         cMotBx      := substr( aMotBx[ascan( aMotBx, {|x| cXMotBx $ alltrim(x) } )] , 1, 3)
         Work_Pgto->EEQ_SLDELI := Work_Pgto->EEQ_SALDO
         Work_Pgto->EEQ_SALDO  := 0
      EndIf

   ElseIf Empty(Work_Pgto->EEQ_FAOR) .AND. Empty(Work_Pgto->EEQ_SALDO)
       If MSGYESNO(STR0084) //"Confirma Restauração de Saldo?"
         Work_Pgto->EEQ_SALDO  := Work_Pgto->EEQ_SLDELI
         Work_Pgto->EEQ_SLDELI := 0
       EndIf
   ElseIf Work_Pgto->EEQ_FAOR == "F"
      MsgStop(STR0032+Replic(ENTER,2)+; //"Este adiantamento não pode ser alterado."
              STR0033+ENTER+;  //"Detalhes:"
              STR0081+ENTER+;  //"Este adiantamento está vinculado a contrato de financiamento, para excluir o mesmo "
              STR0082,STR0007) //"favor estornar o contrato de financiamento correspondente."###"Atenção"
      Break
   Else
      MsgStop(STR0085, STR0007) //"Não foi possível Eliminar/Resturar este processo, por ser um adiantamento vinculado.", "Atenção"
      Break
   EndIf

End Sequence

Return Nil
/**********************************
FUnção para validar campos vazio
***********************************/
static function valid_banco(cXBanco,cXAgenc,cXConta,cXMotBx)
Local lRet := .F.

   if ( empty(cXBanco) .or. empty(cXAgenc) .or. empty(cXConta) .or. empty(cXMotBx) )

      easyhelp("Escolha um banco com agência e conta ou slecione um motivo de baixa.", STR0007)
      lRet := .T.

   elseif SA6->A6_BLOCKED=="1"

      easyhelp("Banco com movimentos em conta bloqueado.", STR0007)
      lRet := .T.

   elseif (!empty(SA6->A6_MOEEASY) .and. SA6->A6_MOEEASY # Work_Pgto->EEQ_MOEBCO) .or. (EECGetMoeda(SA6->A6_MOEDA) # Work_Pgto->EEQ_MOEBCO) //Work_Pgto->EEQ_MOEDA

      easyhelp("Não é possível selecionar um banco para a baixa com moeda diferente da moeda do banco do adiantamento.", STR0007)
      lRet := .T.

   endif

return lRet
/**********************************
Busca a moeda no cadastro
***********************************/
Function EECGetMoeda(cXMoeda)
local aAreaSYF := SYF->( getarea() )
Local cRet := ""

   SYF->( DBGOTOP() )
   SYF->( dbeval( {|| cRet := YF_MOEDA } , {|| YF_MOEFAT == cXMoeda } ) )

   if empty(cRet)
      easyhelp("Moeda não relacionada no cadastro de moedas.", STR0007)
   endif

restarea(aAreaSYF)
Return cRet
/*
*-----------------------------------------------------------*
/ Funcao.....: AC100Banco()                                 /
/ Parâmetros.: -                                            /
/ Objetivos..: Inserção de Bancos Cobradores do Importador  /
/ Autor......: Guilherme Fernandes Pilan - GFP              /
/ Data/Hora..: 09/11/2010 - 15:35                           /
/ Revisão....: -                                            /
/ Obs........: -                                            /
*-----------------------------------------------------------*
*/
*--------------------------------*
 Static Function AC100Banco()
*--------------------------------*
Local   oDlg, oGetDb
Local   aPos[0]
Local   bOk     := {|| If (AC100BcoVld() , (nOpcEWR := 1 ,oDlg:End()) , nOpcEWR := 0)},;
        bCancel := {||nOpcEWR := 0,oDlg:End()}
Local   lSeek := .F.
Local   i, j
Private aAlter  := {"EWR_BCOCOB","EWR_COBCOD","EWR_COBDEP",;
                    "EWR_COBEND","EWR_COBCID","EWR_COBPAI"}

WorkEWR->(DBGoTop())
If WorkEWR->(Eof()) .And. WorkEWR->(BoF())
   WorkEWR->(DbAppend())
EndIf

// Carrega Tela
DEFINE MSDIALOG oDlg FROM 200,100 TO 400,900 TITLE 'Bancos Cobradores' OF oMainWnd PIXEL

aPos := PosDlg(oDlg)


oGetDb := MsGetDb():New(aPos[1],aPos[2],aPos[3]-4,aPos[4],;  // Posições da Tela
                        4,;                                  // Tipo (Inclusão, Alt., etc.)
                        ,;                                   // cLinhaOk
                        ,;                                   // cTudoOk
                        ,;                                   // cIncrementa
                        .T.,;                                // Permite deleção de registros
                        aAlter,;                             // Campos que podem ser alterados
                        0,;                                  // Nro. de Colunas que serão congeladas
                        .F.,;                                // Habilita validação da primeira coluna do aCols para esta não poder estar vazia.
                        ,;                                   // Parâmetro reservado (uPar1).
                        "WorkEWR",;                          // Work que será mostrada no Browse
                        "AC100ValCampo",;                    // Função executada na validação do campo.
                        ,;                                   // Parâmetro reservado (lCondicional)
                        .T.,;                                // Linha em branco caso seja inclusão de novo registro (lAppend)
                        oDlg,;                               // Objeto no qual está inserida a MsGetDb
                        .T.,,;                               // Define se vai utilizar características do dicionário (gatilhos, consultas...)
                        ,;                                   // Parâmetro reservado (uPar2).
                        ,;                                   // Função que valida exclusão
                         )                                   // Função executada quando pressionada as teclas <Ctrl>+<Delete>

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,/*@aButtons*/,)) CENTERED

//FDR - 12/09/11
If nOpcEWR = 1
   aWkHist := {}
   aAdd(aWkHist,{"EWR_BCOCOB", "EWR_COBCOD", "EWR_COBDEP", "EWR_COBEND", "EWR_COBCID",;
                 "EWR_COBPAI", "EWR_ALI_WT", "EWR_REC_WT", "EWR_FLAG"})

   WorkEWR->(DbGoTop())
   Do While WorkEWR->(!EOF())
      aAdd(aWkHist,{WorkEWR->EWR_BCOCOB, WorkEWR->EWR_COBCOD, WorkEWR->EWR_COBDEP, WorkEWR->EWR_COBEND, WorkEWR->EWR_COBCID,;
                    WorkEWR->EWR_COBPAI, WorkEWR->EWR_ALI_WT, WorkEWR->EWR_REC_WT, WorkEWR->EWR_FLAG})
      WorkEWR->(DBSkip())
   EndDo

ElseIf nOpcEWR = 0

   WorkEWR->(avzap())
   For i := 2 To Len(aWkHist)
      WorkEWR->(DbAppend())
      For j := 1 To Len(aWkHist[i])
          If WorkEWR->(FieldPos(aWkHist[1][j])) > 0
             WorkEWR->&(aWkHist[1][j]):= aWkHist[i][j]
          EndIf
      Next j
   Next i

EndIf

Return .T.

/*
Funcao          : AC100BcoVld()
Parametros      : -
Objetivos       : Verifica se o campo CONGER Bco. está preenchido.
Autor           : Flavio Danilo Ricardo
Data/Hora       : 06/09/2011
*/

*-------------------------*
Function AC100BcoVld()
*-------------------------*

Local lRet   := .T.
Local nLinha := 0

Begin Sequence

   WorkEWR->(DbGoTop())
   Do While WorkEWR->(!Eof()) .And. lRet
      nLinha++
      If Empty(WorkEWR->EWR_COBCOD)
         Msginfo("Informe o campo '"+AllTrim(AvSx3("EWR_COBCOD",AV_TITULO))+"' na linha "+AllTrim(Str(nLinha))+".","Atenção")
         lRet := .F.
         Break
      EndIf
      WorkEWR->(DBSkip())
   EndDo

End Sequence

Return lRet

/*
Funcao          : AC100ValCampo()
Parametros      : -
Objetivos       : Validação dos campos da MsGetDb()
Autor           : Flavio Danilo Ricardo
Data/Hora       : 09/09/2011
*/

*-------------------------*
Function AC100ValCampo()
*-------------------------*

Local lRet   := .T.
Local nLinha := 0
Local cCampo := "",;
      cCompara := "",;
      cMsg := ""

If Type("M->EWR_COBCOD") <> "U"
   cCampo := "M->EWR_COBCOD"
   cCompara := "WorkEWR->EWR_COBCOD"
   cMsg := "Código já cadastrado, por favor informe um novo código."
Endif

Begin Sequence

   If !Empty(cCampo)
      WorkEWR->(DbGoTop())
      Do While WorkEWR->(!Eof()) .And. lRet
         nLinha++
         If AllTrim(&cCampo) == AllTrim(&cCompara) .And. nBrLin <> nLinha //Conteudo igual e numero da linha diferente
            MsgInfo(cMsg, "Atenção")
            lRet := .F.
            Break
         EndIf
         WorkEWR->(DBSkip())
      EndDo
   EndIf

End Sequence

WorkEWR->(DBGoTo(nBrLin))

Return lRet

/*
Funcao          : AC100VldOk()
Parametros      : AC100VldOk_IncAltExc
Objetivos       : Retornar .T. ou .F. no botão Ok final na Inclusão, Alteração e Exclusão de Empresas
Autor           : Diogo Felipe dos Santos
Data/Hora       : 25/11/2010/10:00
Revisao         : Wilsimar Fabrício da Silva
Obs             :
*/

*------------------------------*
Function AC100VldOk(nOpc)
*------------------------------*

Private lValImpCli := .T.

lValImpCli := AC100ValAdiantOK(nOpc)

IF EasyEntryPoint("EECAC100")
   ExecBlock("EECAC100",.F.,.F.,{"AC100VldOk_IncAltExc",lValImpCli})
Endif

Return lValImpCli

/* ======================================================================================*
* Função: IntegDef
* Aviso: A integDef para Import./Cliente é a mesma utilizada para Fornecedores e Empresas.
* Presente no fonte EECAC175.PRW.
* =======================================================================================*/
/*========================================================================================
Funcao Adapter: AC100ARECB
Parametros    : "oMessage" - Objeto XML com conteúdo da tag "BusinessContent" recebida
Retorno       : aExecAuto onde:
                aExecAuto[1] = Array com os dados de capa para ExecAuto
                         [1][1] = Identificador de capa ("CAB")
                         [1][2] = Id do Formulario de Capa
                         [1][3] = Array com os registros para ExecAuto
                aExecAuto[2] = Array com os dados de detalhe para ExecAuto
                         [2][1] = Identificador de detalhe ("DET")
                         [2][2] = Id do Formulario de Detalhe
                         [2][3] = Array com os registros para ExecAuto
Objetivos     : Montar o Array de dados da Mensagem única para inserção via ExecAuto
Autor         : Felipe Sales Martinez - FSM
Data/Hora     : 30/11/2011 - 10:00 hs
Revisao       : FSM - 06/01/2012
Obs.          :
==========================================================================================*/
*------------------------------------------------*
Function AC100ARECB(oMessage)
*------------------------------------------------*
Local oBusinessCont := oMessage:GetMsgContent()
Local oBatch    := EBatch():New()
Local oExecAuto := EExecAuto():New()
Local oParams   := ERec():New()
Local oRec      := ERec():New()
Local cPessoa   := Upper(AllTrim(EasyGetXMLinfo(, oBusinessCont, "_EntityType")))
Local nTotBanco := 0, nCont := 0
Local cCampo := ""
Local lObrigat := .T.
Local aContatos := {}, k
Local oContatos, oContato
Local cCodPais := ""
    /* Definindo Funcao do ExecAuto */
    oParams:SetField("cMainAlias","SA1")
    oParams:SetField("bFunction",{|oEasyMessage| EECAC100(oEasyMessage:GetEAutoArray("SA1"),EasyEAutItens("SA1","EE3",oEasyMessage:GetEAutoArray("SA1"),oEasyMessage:GetEAutoArray("EE3"),"A1_FILIAL+'I'+AvKey(A1_COD,'EE3_CONTAT')+AvKey(A1_LOJA,'EE3_COMPL')"), oEasyMessage:GetOperation())})

    AddArrayXML(oRec, "A1_COD"    , oBusinessCont ,"_Code" , lObrigat )//Codigo
	oRec:SetField("A1_LOJA"  , AvKey(".","A1_LOJA")  )  //Loja
	AddArrayXML(oRec, "A1_NOME"   , oBusinessCont ,"_Name" , lObrigat )  //Nome completo
	AddArrayXML(oRec, "A1_NREDUZ" , oBusinessCont ,"_ShortName" , lObrigat ) //Nome Fantasia
    oRec:SetField("A1_TIPO", AvKey("X","A1_TIPO") ) //Tipo

	If cPessoa == "PERSON"
       cPessoa := "F"
    ElseIf cPessoa == "COMPANY"
       cPessoa := "J"
    EndIf
	If !Empty(cPessoa)
	    oRec:SetField("A1_PESSOA", AvKey(cPessoa,"A1_PESSOA") ) //Fisic/Jurid
	EndIf

	AddArrayXML(oRec, "A1_VM_OBS", oBusinessCont ,"_Comments" )  //Observacoes

    If SA1->(FieldPos("A1_NIF")) > 0 .AND. !Empty(EasyGetCommonValue(oBusinessCont, "NIF"))
       oRec:SetField("A1_NIF", AvKey(EasyGetCommonValue(oBusinessCont, "NIF"),"A1_NIF") ) //CNPJ/CPF
    EndIf

	If IsCpoInXML(oBusinessCont, "_Address")

		//AddArrayXML(oRec, "A1_END"    , oBusinessCont:_Address ,"_Address" , lObrigat ) //Endereço
		oRec:SetField("A1_END", AvKey(oBusinessCont:_Address:_Address:TEXT +", "+ ;
		If( IsCpoInXML(oBusinessCont:_Address, "_Number") , AllTrim(EasyGetXMLinfo(,oBusinessCont:_Address, "_Number")) , ""),"A1_END") )

		oRec:SetField("A1_BAIRRO", If( IsCpoInXML(oBusinessCont:_Address, "_District") , AllTrim(EasyGetXMLinfo(,oBusinessCont:_Address, "_District")), "") )

        AddArrayXML(oRec, "A1_MUN"    , oBusinessCont:_Address:_City ,"_Description"  , lObrigat ) //Municipio

       cCodPais := ""                                                                                           //NCF - 21/05/2015 - Integrar estado do fornecedor como "EX" quando o país for estrangeiro.
       If IsCpoInXML(oBusinessCont:_Address, "_Country")
	      cCodPais := AvKey(EasyConvCod( oBusinessCont:_Address:_Country:_Code:Text, "SYA" ), "A1_PAIS")
       EndIf

       If !Empty(cCodPais) .And. Alltrim(cCodPais) <> "105"
          oRec:SetField("A1_EST", "EX")
       Else
          AddArrayXML(oRec, "A1_EST" , oBusinessCont:_Address:_State, "_Code") //Estado
       EndIf


		cState := EasyGetXMLinfo("A1_EST", oBusinessCont:_Address:_State, "_Code")
		If !SX5->(dbSetOrder(1),dbSeek(xFilial()+"AC"+cState))
		   cState := "EX"
		EndIf

		oRec:SetField("A1_EST",cState)
		//AddArrayXML(oRec, "A1_EST"    , oBusinessCont:_Address:_State ,"_Code" , lObrigat )  //Estado
		AddArrayXML(oRec, "A1_CEP"    , oBusinessCont:_Address ,"_ZIPCode") //CEP
     	oRec:SetField("A1_CXPOSTA", If( IsCpoInXML(oBusinessCont:_Address, "_POBox") , AllTrim(EasyGetXMLinfo(,oBusinessCont:_Address, "_POBox")), "") )
		AddArrayXML(oRec, "A1_COMPLEM"    , oBusinessCont:_Address ,"_Complement" ) //Complemento

		/*If IsCpoInXML(oBusinessCont:_Address, "_Country")
		   cCodPais := AvKey(EasyConvCod( oBusinessCont:_Address:_Country:_Code:Text, "SYA" ), "A1_PAIS")
		   If !Empty(cCodPais)
		      oRec:SetField("A1_PAIS",cCodPais)
		   EndIf
		EndIf*/
		If !Empty(cCodPais)
           oRec:SetField("A1_PAIS", cCodPais)
        Endif

	EndIf
	/*
	//NCF - 22/05/2014 - Integração do campo NIF conforme a versão 1_002 do xsd "CustomerVendor"
	If IsCpoInXML(oBusinessCont, "_NIF")
       AddArrayXML(oRec, "A1_NIF" , oBusinessCont ,"_NIF" , lObrigat )
    EndIf
	*/
	If IsCpoInXML(oBusinessCont, "_ListOfCommunicationInformation")
	   If ValType(oBusinessCont:_ListOfCommunicationInformation:_CommunicationInformation) == "A"
	      aInfoCli := oBusinessCont:_ListOfCommunicationInformation:_CommunicationInformation
	   Else
	      aInfoCli := {oBusinessCont:_ListOfCommunicationInformation:_CommunicationInformation}
	   EndIf

	   If IsCpoInXML(aInfoCli[1], "_PhoneNumber")
	   	  /* AAF - NOPADO POIS NO LOGIX NAO EXISTE PADRAO DE FORMATACAO DE TELEFONE.
	      //Considera a mascara DDI-DDD-TELEFONE. Ou seja, considera o traço "-" como separador de DDI, DDD e TELEFONE
		  aTel := EasyStrSplit(AllTrim(EasyGetXMLinfo(,aInfoCli[1], "_PhoneNumber")),"-")

		  If Len(aTel) >= 3
		     cTel := aTel[3]
			 cDDD := aTel[2]
		     cDDI := aTel[1]
	      ElseIf Len(aTel) == 2
		     cTel := aTel[2]
			 cDDD := aTel[1]
		     cDDI := ""
	      ElseIf Len(aTel) == 1
		     cTel := aTel[1]
			 cDDD := ""
		     cDDI := ""
		  EndIf

          oRec:SetField("A1_TEL", cTel)
		  oRec:SetField("A1_DDI", cDDI)
		  oRec:SetField("A1_DDD", cDDD)
		  */
		  oRec:SetField("A1_TEL",AllTrim(EasyGetXMLinfo(,aInfoCli[1], "_PhoneNumber")))
	   EndIf
       If IsCpoInXML(aInfoCli[1], "_FaxNumber")
	      /* AAF - NOPADO POIS NO LOGIX NAO EXISTE PADRAO DE FORMATACAO DE TELEFONE.
		  //Considera a mascara DDI-DDD-TELEFONE. Ou seja, considera o traço "-" como separador de DDI, DDD e TELEFONE
	      aTel := EasyStrSplit(AllTrim(EasyGetXMLinfo(,aInfoCli[1], "_FaxNumber")),"-")

		  If Len(aTel) >= 3
		     cTel := aTel[3]
			 cDDD := aTel[2]
		     cDDI := aTel[1]
	      ElseIf Len(aTel) == 2
		     cTel := aTel[2]
			 cDDD := aTel[1]
		     cDDI := ""
	      ElseIf Len(aTel) == 1
		     cTel := aTel[1]
			 cDDD := ""
		     cDDI := ""
		  EndIf
		  */
          oRec:SetField("A1_FAX", AllTrim(EasyGetXMLinfo(,aInfoCli[1], "_FaxNumber")))
	   EndIf

       //oRec:SetField("A1_TELEX",If( IsCpoInXML(aInfoCli[1], "_PhoneExtension") , AllTrim(EasyGetXMLinfo(,aInfoCli[1], "_FaxNumber")),      "") )
       oRec:SetField("A1_HPAGE",If( IsCpoInXML(aInfoCli[1], "_HomePage")       , AllTrim(EasyGetXMLinfo(,aInfoCli[1], "_HomePage")),       "") )
       oRec:SetField("A1_EMAIL",If( IsCpoInXML(aInfoCli[1], "_Email")          , AllTrim(EasyGetXMLinfo(,aInfoCli[1], "_Email")),          "") )

       //tipo do cliente para que o cadastro integrado possa ser usado no pedido de exportação quando o fluxo for SIGAEEC -> ERP
       oRec:SetField("A1_TIPCLI", "4") //Todos
	EndIf
	If IsCpoInXML(oBusinessCont, "_ListOfBankingInformation")
		/* Tratamento para Bancos */
		If ValType(oBusinessCont:_ListOfBankingInformation:_BankingInformation) <> "A"
       		XmlNode2Arr(oBusinessCont:_ListOfBankingInformation:_BankingInformation ,"_BankingInformation")
    	EndIf
	    //verificando se a quantidade de banco do xml é inferior a quantidade de banco do cliente que é igual a 5.
		If Len(oBusinessCont:_ListOfBankingInformation:_BankingInformation) > 5
		   nTotBanco := 5
		Else
		   nTotBanco := Len(oBusinessCont:_ListOfBankingInformation:_BankingInformation)
		EndIf
		For nCont := 1 To nTotBanco
		    cCampo := "A1_BCO" + AllTrim(Str(nCont))
		    AddArrayXML(oRec, cCampo, oBusinessCont:_ListOfBankingInformation:_BankingInformation[nCont] ,"_BankCode" )  //Bancos
		Next
	EndIf

	aContatos := {}
	If IsCpoInXML(oBusinessCont,"_ListOfContacts") .And. IsCpoInXML(oBusinessCont:_ListOfContacts,"_Contact")
		If ValType(oBusinessCont:_ListOfContacts:_Contact) == "A"
			aContatos := oBusinessCont:_ListOfContacts:_Contact
		Else
			aContatos := {oBusinessCont:_ListOfContacts:_Contact}
		EndIf
	EndIf

    oContatos := ETab():New()
	For k := 1 To Len(aContatos)
		oContato := ERec():New()
		// Chave - EE3_FILIAL+EE3_CODCAD+EE3_CONTAT+EE3_COMPL+EE3_SEQ
		oContato:SetField("EE3_CODCAD", AvKey("I","EE3_CODCAD") )
		oContato:SetField("EE3_CONTAT", AvKey(EasyGetXMLinfo(, oBusinessCont, "_Code"),'EE3_CONTAT') )
		oContato:SetField("EE3_COMPL", AvKey(".","EE3_COMPL") )

		oContato:SetField("EE3_SEQ", StrZero(k,AvSX3("EE3_SEQ",AV_TAMANHO)) )
		AddArrayXML(oContato, "EE3_NOME", aContatos[k] ,"_Name"  )
		AddArrayXML(oContato, "EE3_CARGO", aContatos[k] ,"_Title"  )
		AddArrayXML(oContato, "EE3_DEPART", aContatos[k] ,"_Department"  )

		If IsCpoInXML(aContatos[k],"_CommunicationInformation")
			AddArrayXML(oContato, "EE3_FONE", aContatos[k]:_CommunicationInformation,"_PhoneNumber")
			//AddArrayXML(oRec, "EE3_FONE", aContatos[k]:_CommunicationInformation,"_PhoneExtension")
			AddArrayXML(oContato, "EE3_FAX", aContatos[k]:_CommunicationInformation,"_FaxNumber")
			//AddArrayXML(oRec, "EE3_FAX", aContatos[k]:_CommunicationInformation,"_FaxNumberExtension")
			//AddArrayXML(oRec, "", aContatos[k]:_CommunicationInformation,"_HomePage")
 			AddArrayXML(oContato, "EE3_EMAIL", aContatos[k]:_CommunicationInformation,"_Email")
		EndIf

		oContatos:AddRec(oContato)
	Next k

    /* Definindo Objeto do ExecAuto */
    oExecAuto:SetField("SA1",oRec)
    oExecAuto:SetField("EE3",oContatos )
    oExecAuto:SetField("PARAMS",oParams)

    oBatch:AddRec(oExecAuto)

Return oBatch
/*
Funcao      : AC100BxAdian(cPROR, cPAOR, cFAOR, cTitulo, dDtLiq).
Parametros  : cPROR - Processo de Origem
            : cPAOR - Parcela de Origem
            : cFAOR - Fase de Origem
            : cTitulo - Titulo gerado no FIN
            : dDtLiq - Data de Liquidação da parcela
            : nTaxa - Taxa da liquidação
Retorno     : lRet - Resultado da baixa.
Objetivos   : Efetuar baixa de adiantamentos vinculados em embarques quando estes já foram embarcados.
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 31/08/2012 :: 16:00
*/
*-------------------------------------------------------------*
Function AC100BxAdian(cPROR, cPAOR, cFAOR, cTitulo, dDtLiq, nTaxa)
*-------------------------------------------------------------*
Local aOrd := SaveOrd({"EEQ","EEC","SE1"})
Local lRet := .T. //FSM - 19/10/2012
Local aCampos := {"EEQ_NRINVO","EEQ_PGT","EEQ_SOL","EEQ_DTNEGO","EEQ_NROP","EEQ_TX","EEQ_EQVL"}
Local i
Private nValorBaixa, dDtBaixa

RegToMemory("EEQ", .F.)

EEQ->(DbSetOrder(7)) //EEQ_FILIAL+EEQ_FAOR+EEQ_PROR+EEQ_PAOR
If EEQ->(DbSeek(xFilial("EEQ")+cFAOR+cPROR+cPAOR))
   EEC->(DbSetOrder(1))
   If EEC->(DbSeek(xFilial("EEC")+EEQ->EEQ_PREEMB)) .And. !Empty(EEC->EEC_DTEMBA)
      If !Empty(cTitulo) .AND. !Empty(dDtLiq) .AND. EEQ->EEQ_TIPO == "A" .AND. EEQ->EEQ_FASE == "E"
         SE1->(DbSetOrder(1))  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
         If SE1->(DbSeek(xFilial("SE1") + "EEC" + AvKey(cTitulo,"E1_NUM")))
            nValorBaixa:= EEQ->EEQ_VL*nTaxa
            dDtBaixa   := dDtLiq
            lRet := AvStAction("008") //Baixa de Titulo a Receber

            If RecLock("EEQ", .F.)
               For i := 1 To Len(aCampos)
                  EEQ->&(aCampos[i]) := M->&(aCampos[i])
               Next
               EEQ->(MsUnlock())
            EndIf
         EndIf
      EndIf
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return lRet


/*
Funcao      : AC100ValAdiantOK
Objetivos   : Valida se ha algum adiantamento vinculado com um contrato de financiamento.
Autor       : Felipe Sales Martinez - FSM
Data/Hora   : 05/10/2012
*/
Static Function AC100ValAdiantOK(nOpc)
Local lRet := .T.
Local aOrd := SaveOrd({"EEQ"})

Begin Sequence
	If nOpc == EXCLUIR
	   EEQ->(DbSetOrder(6)) // Fase+Preemb+Parcela"
       If EEQ->(DbSeek(xFilial("EEQ")+"C"+AvKey(SA1->A1_COD+SA1->A1_LOJA,"EEQ_PREEMB")))
			Do While EEQ->(!EOF()).And. EEQ->(EEQ_FILIAL+EEQ_FASE+EEQ_PREEMB) == xFilial("EEQ")+"C"+AvKey(SA1->A1_COD+SA1->A1_LOJA,"EEQ_PREEMB")
				If EasyIsVincAdiant(nOpc, EEQ->EEQ_NRINVO, EEQ->EEQ_PARC )
					lRet := .F.
					Exit
				EndIf
				EEQ->(DBSkip())
			EndDo
       EndIf
	EndIf
End Sequence

RestOrd(aOrd)
Return lRet

/*
Funcao     : AC100F3VIA()
Parametros : Tipo de filtro
Retorno    : Nenhum
Objetivos  : Adiciona Filtro nas consultas padrão YR1/YR11
Autor      : Guilherme Fernandes Pilan - GFP
Revisão    : Laercio G S Junior - LGS
Revisão    : WFS - 13/05/2015 - reestruturação
Data/Hora  : 12/09/2014 - 24/11/2014
*/
*-------------------------*
Function AC100F3VIA(nTipo)
*-------------------------*
Local lRet    := .T.
Local aOrd    := SaveOrd({"SYR"})
Local nOrd
Default nTipo := 0

Begin Sequence

   If "M->" $ ReadVar()
       cDest := Right(ReadVar(),Len(ReadVar())-3)
   EndIf

   If Type("cCampoF3") == "U"
      cCampoF3:= ""
   EndIf
   If Type("cDest") == "U"
      cDest:= ""
   EndIf

   If !Empty(cDest)
      DO CASE
         CASE cDest $ "EXJ_ORI_1|EXJ_ORI_2|EXJ_ORI_3"
            IF cDest        == "EXJ_ORI_1"
               cCampoF3     := "M->A1_DEST_1"
            ELSEIF cDest == "EXJ_ORI_2"
               cCampoF3     := "M->A1_DEST_2"
            ELSEIF cDest == "EXJ_ORI_3"
               cCampoF3     := "M->A1_DEST_2"
            ENDIF
            nOrd:= 4 //YR_FILIAL+YR_DESTINO

         CASE cDest $ "A1_DEST_1|A1_DEST_2|A1_DEST_3"
            IF cDest        == "A1_DEST_1"
               cCampoF3     := "M->EXJ_ORI_1"
            ELSEIF cDest == "A1_DEST_2"
               cCampoF3     := "M->EXJ_ORI_2"
            ELSEIF cDest == "A1_DEST_3"
               cCampoF3     := "M->EXJ_ORI_3"
            ENDIF
            nOrd:= 3 //YR_FILIAL+YR_ORIGEM

         OtherWise
            Break
      ENDCASE
   EndIf

   /* comentado por WFS
   DO WHILE SYR->(!EOF()) .AND. !EMPTY(&cCampoF3)
       IF nTipo == 1
          IF !EMPTY(&cCampoF3)
               lRet := SYR->YR_PAIS_OR == '105' .AND. SYR->YR_DESTINO == &cCampoF3
              Return lRet
               SYR->(DBSKIP())
          ENDIF
       ELSEIF nTipo == 2
          IF !EMPTY(&cCampoF3)
               lRet := SYR->YR_PAIS_OR == '105' .AND. SYR->YR_ORIGEM == &cCampoF3
              Return lRet
               SYR->(DBSKIP())
          ENDIF
       ENDIF
   ENDDO*/

   If Empty(&(cCampoF3))
      Break
   EndIf

   SYR->(DBSetOrder(nOrd))
   If SYR->(DBSeek(xFilial() + &(cCampoF3)))
      If nModulo == 17
         lRet := SYR->YR_PAIS_OR <> '105'
         Break
      Else
         lRet := SYR->YR_PAIS_OR == '105'
         Break
      EndIf
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet
/*
*---------------------------------------------------------*
/ Funcao....: AjustaEC6()                                 /
/ Parametro.:                                             /
/ Objetivos.: Ajustar tipo dos eventos de Adiantamento    /
/ Autor.....: Nilson César C. Filho                       /
/ Data/Hora.: 01/10/2015 - 18:50                          /
/ RETORNO...: TRUE                                        /
/ Obs.......:                                             /
*---------------------------------------------------------*
*/
*--------------------------------*
Static Function AjustaEC6()
*--------------------------------*

If ChkFile("EC6")

   EC6->(DbSetOrder(1))

   If EC6->(DbSeek(xFilial("EC6") +  AvKey("EXPORT","EC6_TPMODU") + AvKey("602","EC6_ID_CAM") )) //Adto. Pedido pré-embarque
      If EC6->EC6_RECDES == '2'
         EC6->(RecLock("EC6",.F.))
         EC6->EC6_RECDES := '1'
         EC6->(MsUnlock())
      EndIf
   EndIf

   If EC6->(DbSeek(xFilial("EC6") +  AvKey("EXPORT","EC6_TPMODU") + AvKey("605","EC6_ID_CAM") )) //Adto. Cliente pré-embarque
      If EC6->EC6_RECDES == '2'
         EC6->(RecLock("EC6",.F.))
         EC6->EC6_RECDES := '1'
         EC6->(MsUnlock())
      EndIf
   EndIf

   If EC6->(DbSeek(xFilial("EC6") +  AvKey("EXPORT","EC6_TPMODU") + AvKey("607","EC6_ID_CAM") )) //Adto. Pedido pós-embarque
      If EC6->EC6_RECDES == '2'
         EC6->(RecLock("EC6",.F.))
         EC6->EC6_RECDES := '1'
         EC6->(MsUnlock())
      EndIf
   EndIf

EndIf

Return .T.

/*
Funcao     : AtualizaNIF()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Replica informação do campo SA1 para o EXJ quando manual 10
Autor      : Marcos Roberto Ramos Cavini Filho - MCF
Data/Hora  : 18/08/2016 - 08:56
*/
*-------------------------*
Function AtualizaNIF()
*-------------------------*

EXJ->(DbSetOrder(1))
   If EXJ->(DbSeek(xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA))
      If Empty(EXJ->EXJ_NIF)
         EXJ->(RecLock("EXJ",.F.))
         EXJ->EXJ_NIF  := SA1->A1_NIF
         EXJ->EXJ_MOTNIF := ""
         EXJ->(MsUnLock())
      EndIf
   Else
      EXJ->(RecLock("EXJ",.T.))
      EXJ->EXJ_COD  := SA1->A1_COD
      EXJ->EXJ_LOJA := SA1->A1_LOJA
      EXJ->EXJ_NIF  := SA1->A1_NIF
      EXJ->EXJ_MOTNIF := ""
      EXJ->(MsUnLock())
   EndIf

Return
/*
Funcao     : ClrBufADP()
Parametros : nRecEEQ - Recno da EEQ
Retorno    : Nenhum
Objetivos  : Chamar funções que manipulam array estático da integração do adapter EECAF212
             para exclusão de registros da lista de recnos.
Autor      : NCF - Nilson César
Data/Hora  : 07/11/2018 - 11:30
*/
*-----------------------------------*
Static Function ClrBufADP(nRecEEQ)
*-----------------------------------*
Local aDadosRcp,nPosAdp

// NCF - 06/11/2018 - recuperar buffer com os recnos das parcelas tratadas pelo ADAPTER EECAF212
If FindFunction("GetDataInt")
   aDadosRcp := GetDataInt()
EndIf

If ValType(aDadosRcp) == "A"
   If( nPosAdp := aScan(aDadosRcp, {|x| x[1] == "EECAF212" .And. x[2] == nRecEEQ } ) ) > 0
      If FindFunction("DelDataInt")
         DelDataInt( nPosAdp )
      EndIf
   EndIf
EndIf 

Return

*------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAC100.PRW                                           *
*------------------------------------------------------------------------*
