/*
Programa..: EECAC170.PRW
Objetivo..: Cadastro de Disponibilade de Navios
Autor.....: Ricardo Dumbrovsky
Data/Hora.: 07/25/02 13:00
Obs.......: LCS - 13/09/2002 - CORRECAO DO PRW PARA GRAVAR O CAMPO MEMO
*/
#INCLUDE "EECAC170.ch" 
#INCLUDE "EEC.CH"
*--------------------------------------------------------------------
FUNCTION EECAC170A(lExecute,nReg,nOpc)
Local nOldArea:=Select(),cAlias:="EE6", nRecSX3 := SX3->( recno() )
Default lExecute:= .F.
Private aRotina := MenuDef()
Private cCadastro := STR0006, aDeletados := {}  //"Cadastro de Navios"
Private aMemos := {{"EE6_OBS","EE6_VM_OBS"}}

If !lExecute      
   SX3->( dbSetOrder(2) )
   SX3->( dbgotop() )
   If !SX3->( dbSeek("EE6_VIAGEM") )
      EECAC170()  // Versão 6.09
      Return(.T.)
   Endif
   SX3->( dbSetorder(1) )
   SX3->( dbGoto(nRecSX3) )   
   (cAlias)->(dbSetOrder(1))

   mBrowse(6,1,22,75,cAlias)
   dbSelectArea(nOldArea)
Else
   AC170MAN(cAlias,nReg,nOpc)
EndIf   
Return(NIL)                 

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 18/01/07 - 11:07
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina :=  {  { STR0001,"AxPesqui"   ,0,1},;   //"Pesquisar"
                     { STR0002,"AC170MAN"   ,0,2},;   //"Visualizar"
                     { STR0003,"AC170MAN"   ,0,3},;   //"Incluir"
                     { STR0004,"AC170MAN"   ,0,4},;   //"Alterar"
                     { STR0005,"AC170MAN"   ,0,5,3}}  //"Excluir"

IF(EasyEntryPoint("EECAC170"),Execblock("EECAC170",.F.,.F.,"AROTINA"),)

//³ P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAC170AMNU")
	aRotAdic := ExecBlock("EAC170AMNU",.f.,.f.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

Return aRotina
*--------------------------------------------------------------------
/*
Funcao      : AC170MAN
Parametros  : nOpc    := Opcao Selecionada
              cTitulo := Titulo da janela
Retorno     : NIL
Objetivos   : Manutencao da tabela de navios
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/25/2002 13:00
Revisao     :
Obs.        :
*/                             
Function AC170MAN(cAlias,nReg,nOpc)
Local nInc, aButtons := {}
Local nOpcA := 0
Local bOk , bCancel := {|| oDlg:End() }
Local aPos,  oDlg
Local aCamposEnc, aNotEic := {"EE6_AGENT1", "EE6_DSCAG1", "EE6_AGENT2", "EE6_DSCAG2", "EE6_AGENT3", "EE6_DSCAG3", "EE6_AGENT4", "EE6_DSCAG4", "EE6_AGENT5", "EE6_DSCAG5"}
Local aSelectFields := {{"EX8_DEST"  ,AVSX3("EX8_DEST"  ,AV_PICTURE),STR0007},; //"Destino"
                        {"EX8_DSCDES",AVSX3("EX8_DSCDES",AV_PICTURE),STR0008},; //"Desc. Destino"
                        {"EX8_TT_ETA",AVSX3("EX8_TT_ETA",AV_PICTURE),AVSX3("EX8_TT_ETA",AV_TITULO)},;
                        {"EX8_ETADES",AVSX3("EX8_ETADES",AV_PICTURE),STR0009},;
                        {"EX8_TT_ETB",AVSX3("EX8_TT_ETB",AV_PICTURE),AVSX3("EX8_TT_ETB",AV_TITULO)},;
                        {"EX8_ETBDES",AVSX3("EX8_ETBDES",AV_PICTURE),AVSX3("EX8_ETBDES",AV_TITULO)},;
                        {"EX8_ETSDES",AVSX3("EX8_ETSDES",AV_PICTURE),AVSX3("EX8_ETSDES",AV_TITULO)}}

Private aCampos :={}, aGets[0], aTela[0]
Private aEnchoice:={"EE6_COD","EE6_NOME","EE6_DT_CON","EE6_BANDEI",;
                    "EE6_DSCBAN","EE6_OBS","EE6_VIAGEM","EE6_ORIGEM",;
                    "EE6_DSCORI","EE6_ETAORI","EE6_ORIGEM","EE6_DSCAGE","EE6_DEADLI"}
Private cNomArq  // GFP - 13/03/2013
Private nOpcCap    := 0
Private nOpcDet    := 0
Private lRecalculo := .F.
               
Begin Sequence
   IF nOpc == INCLUIR
      // CRIAR VARIAVEIS DE MEMORIA ...
      For nInc := 1 TO (cAlias)->(FCount())
          M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next nInc
      bOk := {|| nOpcA:=1, IF(AC170Valid(nOpc),oDlg:End(),nOpcA:=0) }
      nOpcCap := 1
   Else
      For nInc := 1 TO (cALIAS)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
      Next nInc     
      M->EE6_VM_OBS := MSMM(EE6->EE6_OBS,AVSX3("EE6_VM_OBS",AV_TAMANHO),,,LERMEMO)
      If nOpc = VISUALIZAR
         bOK:={||oDlg:End()}
      ElseIf nOpc==ALTERAR
             bOk := {|| nOpcA:=1, IF(AC170Valid(nOpc),oDlg:End(),nOpcA:=0) }
             If ! EE6->(Reclock("EE6",.F.))  // By JPP - 18/04/2005 - 13:20 - Bloquear o registro durante a alteração.
                Break
             EndIf  
      ElseIf nOpc = EXCLUIR
             IF ! INTEGREF("EE6")
                BREAK
             ENDIF
             //(cAlias)->(RECLOCK(cALIAS,.F.))  // By JPP - 18/04/2005 - 13:20
             If ! EE6->(Reclock("EE6",.F.))  // By JPP - 18/04/2005 - 13:20 - Bloquear o registro durante a exclusão.
                Break
             EndIf
             bOk := {|| nOpcA:=2, IF(AC170Valid(nOpc),oDlg:End(),nOpcA:=0) }  //"Confirma Exclusão"###"Atenção"
      EndIf
      nOpcCap := 0
   Endif   
   nEE6Recno := EE6->(Recno())
   //WORK dos detalhes
   AC170CriaTRB()  // GFP - 13/03/2013
   //grava registro no WORK
   AC170GrvTRB()
  
   TRB->(dbGoTop())
   
   //RMD - 23/04/08 - Para não exibir os campos de agente relacionados ao SY5 (EEC) quando estiver no EIC.
   If nModulo == 17
      aCamposEnc := {}
      SX3->(DbSeek(cAlias))
      While SX3->(!Eof() .And. X3_ARQUIVO == cAlias)
         If X3Uso(SX3->X3_USADO) .And. (aScan(aNotEic, {|x| IncSpace(x, 10, .F.) == SX3->X3_CAMPO}) == 0) 
            aAdd(aCamposEnc, SX3->X3_CAMPO)
         EndIf
         SX3->(DbSkip())
      EndDo
   EndIf
   
   nOpcA := 0
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
      
      EnChoice( cAlias, nReg, nOpc, , , , aCamposEnc, PosDlgUp(oDlg), , 3 ) 
      
     //CRF - 05/10/2010 - 14:23  
     aSelectFields := AddCpoUser(aSelectFields,"EX8","2")    
      
      
      oSelect := MsSelect():New("TRB",,,aSelectFields,,,PosDlgDown(oDLG))
      oSelect:bAval := {|| IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),AC170Det(VIS_DET,oSelect),AC170Det(ALT_DET,oSelect)) }
         
   ACTIVATE MSDIALOG oDlg ON INIT AVBar(nOpc,oDlg,bOk,bCancel,ENCH_ADD,{|opc| AC170Det(opc,oSelect)},,) 
   
                                                         
   If nOpcA == 1
      Begin Transaction
         Processa({|| AC170Grava(nReg)})
         //Processa Gatilhos
         EvalTrigger()
         If __lSX8
            ConfirmSX8()
         Endif
      End Transaction
   Elseif nOpcA == 2 
      Begin Transaction       
         EX8->(dbSeek(xFilial()+EE6->EE6_COD))            
         DO While EX8->( !Eof() ) .And. EX8->(EX8_FILIAL+EX8_NAVIO)  == EE6->(EE6_FILIAL+EE6_COD)

            If EX8->(FieldPos("EX8_VIAGEM")) <> 0
               If EX8->EX8_VIAGEM <> EE6->EE6_VIAGEM
                  EX8->(dbSkip())
                  Loop
               EndIf
            EndIf

            EX8->(RecLock("EX8",.F.))
            EX8->(dbDelete())
            EX8->(MSUNLOCK())
            EX8->(dbSkip())
         Enddo
         // LCS - 13/09/2002 - LINHA ABAIXO
         MSMM(M->EE6_OBS,,,,EXCMEMO)
         EE6->(RecLock("EE6",.F.))
         EE6->(dbDelete())
         EE6->(MSUNLOCK())
      End Transaction
   Elseif nOpcA == 0
      EE6->(MSUnlock()) // By JPP - 18/04/2005 -13:20
      If __lSX8
         RollBackSX8()
      Endif
   Endif
End Sequence  

//TRB->(DBCloseArea()) //FSM  - 14/06/2011 
If Select("TRB") > 0
      TRB->(E_EraseArq(cNomArq)) 
EndIf
Return(NIL)
*--------------------------------------------------------------------
/*
Funcao      : AC170GrvTRB
Parametros  : nenhum
Retorno     : .T./.F.
Objetivos   : Grava Destinos
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/25/2002 13:10
Revisao     :
Obs.        :
*/                   
STATIC Function AC170GrvTRB
EX8->(dbSeek(xFilial()+M->EE6_COD ))
DO While EX8->(!Eof()) .And. EX8->(EX8_FILIAL+AllTrim(EX8_NAVIO)) == (XFILIAL("EE6")+Alltrim(M->EE6_COD))

   If EX8->(FieldPos("EX8_VIAGEM")) <> 0
      If AllTrim(EX8->EX8_VIAGEM) <> AllTrim(EE6->EE6_VIAGEM)
         EX8->(dbSkip())
         Loop
      EndIf
   EndIf

   TRB->(dbAppend())
   TRB->RECNO := EX8->(RecNo())
   TRB->TRB_ALI_WT:= "EE6"
   TRB->TRB_REC_WT:= EE6->(Recno())
   AVREPLACE("EX8","TRB")

   EX8->(dbSkip())
   
Enddo
Return (TRB->(EasyRecCount("TRB")) != 0)
*--------------------------------------------------------------------
/*
Funcao      : AC170Grava
Parametros  : cAlias := alias arq.
              nReg   := num.registro
              nOpc   := opcao escolhida
Retorno     : .T. 
Objetivos   : Grava destinos do navio
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/25/2002 13:15
Revisao     :
Obs.        :
*/
STATIC Function AC170Grava(nReg)
LOCAL i
Local lMsg := .f.
*
ProcRegua(TRB->(EasyRecCount("TRB"))+1)
IncProc(STR0012) //"Atualizando arquivos ..."

TRB->(dbGoTop())

IF M->EE6_ETSORI+TRB->EX8_TT_ETA <> TRB->EX8_ETADES
   lMsg := .t.
Endif

// by caf 10/12/2003 19:45 lRecalculo := nOpcCap <> 1 .and. M->EE6_ETSORI <> EE6->EE6_ETSORI .and. MsgYesNo("Deseja recalcular o Transit Time da(s) rota(s) de destino ?")
/*
lRecalculo := lMsg .and. MsgYesNo("Deseja recalcular o Transit Time da(s) rota(s) de destino ?")

IF lRecalculo
   AC170Recalculo(.T.,M->EE6_COD,M->EE6_VIAGEM)
Endif
*/

EE6->(dbGoTo(nEE6Recno))
E_Grava("EE6",Inclui)
// LCS - 13/09/2002 - 2 LINHA ABAIXO
MSMM(M->EE6_OBS,,,,EXCMEMO)
MSMM(,AVSX3("EE6_VM_OBS",AV_TAMANHO),,M->EE6_VM_OBS,INCMEMO,,,"EE6","EE6_OBS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo EX8 (Destinos do Navio)                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DO While ! TRB->(Eof())
   
   IncProc()
   
   IF TRB->RECNO == 0
      EX8->(RecLock("EX8",.T.))
      EX8->EX8_FILIAL := xFilial("EX8")
      EX8->EX8_NAVIO  := EE6->EE6_COD

      If EX8->( FieldPos("EX8_VIAGEM") ) <> 0
         EX8->EX8_VIAGEM := EE6->EE6_VIAGEM
      EndIf
      
   Else
      EX8->(dbGoTo(TRB->RECNO))
      EX8->(RecLock("EX8",.F.))
   Endif
   AVREPLACE("TRB","EX8")   
   EX8->(MSUnlock())      
   TRB->(dbSkip())
Enddo

EE6->(RecLock("EE6",.F.))
EE6->EE6_DESTIN:=EX8->EX8_DEST

For i:=1 To Len(aDeletados)
   IncProc()
   EX8->(dbGoTo(aDeletados[i]))
   EX8->(RecLock("EX8",.F.))
   EX8->(dbDelete())
   EX8->(MSUnlock())
Next i
EE6->(MSUNLOCK())

If EECFlags("INTTRA") .And. !Inclui .And. MsgYesNo("Deseja atualizar as datas do Navio em todos os embarques relacionados?", "Aviso")
   AC170AtuNavio("NAVIO")
   EX8->(DbSeek(xFilial()+EE6->EE6_COD))
   While EX8->(!Eof() .And. EX8_FILIAL+EX8_NAVIO == xFilial()+EE6_COD)
      AC170AtuNavio("DESTINOS")
      EX8->(DbSkip())
   EndDo
EndIf

IF(EasyEntryPoint("EECAC170"),Execblock("EECAC170",.F.,.F.,"FINAL_GRAVA"),) //OMJ - 12/05/2005 

Return (.T.)
*--------------------------------------------------------------------
/*
Funcao      : AC170Det
Parametros  : nOpc := 2 // Visualizacao
                      3 // Inclusao
                      4 // Alteracao
                      5 // Exclusao
Retorno     : NIL
Objetivos   : Manutencao dos Destinos dos navios
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/25/2002 13:20
Revisao     :
Obs.        :
*/
STATIC Function AC170Det(nOpc, oSelect)
Local nAreaOld := Select() 
LOCAL oDlg, nOpcA:=0
LOCAL nInc
LOCAL nReg

LOCAL bOk     := {||nOpcA:=1,IF(AC170ValDet(nOpc,nReg,oDlg),oDlg:End(),nOpcA:=0)} // By JPP - 20/09/2005 17:22 - Atribuir zero a variável nOpcA, substituindo nOpcA=0.
LOCAL bCancel := {|| oDlg:End()}

Private aTela[0][0],aGets[0],nUsado:=0
Private lIncDet := (nOpc == INC_DET) // Variavel utilizada na função AC170AtuCpo

Begin Sequence
   IF nOpc != INC_DET .And. TRB->(EOF()) .AND. TRB->(BOF())
      HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
      Break
   EndIf

   nReg := TRB->(RecNo())

   For nInc := 1 TO TRB->(FCount())
      IF AllTrim(TRB->(FieldName(nInc))) $ "DELETE,DBDELETE,RECNO,TRB_ALI_WT,TRB_REC_WT"
         Loop
      Endif

      IF nOpc == INC_DET // Inclusao
         nOpcDet := 1
         TRB->(M->&(FIELDNAME(nInc)) := CriaVar(FieldName(nInc)))
      Else
         nOpcDet := 0
         TRB->(M->&(FIELDNAME(nInc)) := TRB->(FIELDGET(nInc)))
      Endif
   Next nInc

   If nOpc == INC_DET // INCLUIR       
      M->EX8_NAVIO  := M->EE6_COD
      If EX8->(FieldPos("EX8_VIAGEM")) <> 0
         M->EX8_VIAGEM  := M->EE6_VIAGEM
      EndIf
   EndIf


   While .T.
      nOpcA := 0
      aTela := {}
      aGets := {}
      DEFINE MSDIALOG oDlg TITLE STR0013+M->EE6_COD FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Destinos para o Navio =>"
         EnChoice("EX8", , 3, , , , , PosDlg(oDLG), IF(STR(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},), 3)
      ACTIVATE MSDIALOG oDlg ON INIT AvBar(nOpc,oDlg,bOk,bCancel)
      IF nOpcA == 1 // Ok
         IF nOpc == INC_DET
            TRB->(DBAPPEND())
            nReg := TRB->(RecNo())
         Endif
               
         IF ! Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
            TRB->(DBGOTO(nReg))
            
            For nInc:= 1 TO TRB->(FCount())
               IF AllTrim(TRB->(FieldName(nInc))) $ "RECNO,DELETE,DBDELETE,TRB_ALI_WT,TRB_REC_WT"
                  Loop
               Endif
               TRB->(FieldPut(nInc,M->&(FIELDNAME(nInc))))
            Next
         TRB->TRB_ALI_WT:= "EE6"
         TRB->TRB_REC_WT:= EE6->(Recno())
         EndIF
         
         IF nOpc <> VIS_DET
            //Recalculo do Transit Time das rotas de destino.
            If !IsVazio("TRB") .And. (lRecalculo := MsgYesNo(STR0024)) //"Deseja recalcular o Transit Time da(s) rota(s) de destino ?"
               AC170Recalculo(.T.,M->EE6_COD,M->EE6_VIAGEM)
            EndIf 
         Endif
         
         oSelect:oBrowse:Refresh()
         
         Exit
      Elseif nOpcA == 0 // Cancel
         Exit
      Endif
   Enddo
End Sequence
Select(nAreaOld) // CAF - 27/04/2000 - Enchoice muda a area corrente
Return(NIL)
*--------------------------------------------------------------------
/*
Funcao      : AC170Valid(nOpc)
Parametros  : nOpc := 2 - Visualizacao
                      3 - Inclusao
                      4 - Alteracao
                      5 - Exclusao
Retorno     : .T./.F.
Objetivos   : Consistencias do EX8
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/25/2002 13:25
Revisao     :
Obs.        :
*/
Static Function AC170Valid(nOpc)
LOCAL lRet := .T. 
Private lValidNavio//:= lRet      

Begin Sequence
   IF Str(nOpc,1) $ Str(INCLUIR,1)+"/"+Str(ALTERAR,1)
      IF ! Obrigatorio(aGets,aTela)
         lRet := .F.
         Break
      Endif
      /* ** JPM - Esta validacao foi nopada, para q seja possivel a inclusao de embarcacoes
         sem ser obrigatoria a inclusao de rotas de destino.
        TRB->(dbGoTop())
        IF TRB->(Eof() .And. Bof()) 
           HELP(" ",1,"AVG0005019") //MsgStop("Não existem Tarifas de Fretes cadastradas !","Atenção")
           lRet:=.F.
           Break
        Endif */
        
   Elseif nOpc == EXCLUIR
      IF ! MsgNoYes(STR0014, STR0011) //"Confirma a Exclusão ?"###"Atenção"
         lRet := .F.
         Break 
      Endif
   Endif
End Sequence

   // EJA - 06/12/2017 - Sinalizar se foi clicado no botão Yes ou No.
   lValidNavio := lRet   
   
   //DFS - 17/11/10 - Criação de ponto de entrada para validação de navios.
   If EasyEntryPoint("EECAC170")
      Execblock("EECAC170",.F.,.F.,{"AC170Valid_Navio", nOpc})
   EndIf

If ValType(lValidNavio) == "L"
   lRet:= lValidNavio
   //Break
EndIf

Return(lRet)
*--------------------------------------------------------------------
/*
Funcao      : AC170ValDet
Parametros  : nOpc := 2 // Visualizacao
                      3 // Inclusao
                      4 // Alteracao
                      5 // Exclusao
              nReg := Numero do Registro
Retorno     : .T./.F.
Objetivos   : Consistencias dos detalhes Fretes Maritimos
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/25/2002 13:30
Revisao     :
Obs.        :
*/
STATIC Function AC170ValDet(nOpc,nReg,oDlg)
LOCAL lRet := .T.
Begin Sequence
   IF Str(nOpc,1) $ Str(INC_DET,1)+"/"+Str(ALT_DET,1)
      IF ! Obrigatorio(aGets,aTela)
         lRet := .F.
         Break
      Endif
      //** PLB 15/03/07 - Validação para impedir destinos repetidos
      TRB->( DBGoTop() )
      Do While TRB->( !EoF() )
         If nOpc == INC_DET  .Or.  nReg != TRB->( RecNo() )
            If TRB->EX8_DEST == M->EX8_DEST
               Help(" ",1,"JAGRAVADO")
               AvSetFocus("EX8_DEST",oDlg)
               TRB->( DBGoTo(nReg) )
               lRet := .F.
               Break
            EndIf
         EndIf
         TRB->( DBSkip() )
      EndDo
      TRB->( DBGoTo(nReg) )
      //**

   Elseif nOpc == EXC_DET
      IF MsgNoYes(STR0015) //"Confirma exclusão do Registro Atual ? "
         TRB->(dbGoTo(nReg))
         IF TRB->RECNO != 0
            aAdd(aDeletados,TRB->RECNO)
         Endif
         TRB->(dbDelete())
         TRB->(dbGoTop())
      Else
         lRet := .F.
         Break
      Endif
   Endif
End Sequence
Return(lRet)
*--------------------------------------------------------------------
/*
Funcao      : AC170Crit
Parametros  : cCpo - Nome do Campo a ser validado
Retorno     : .T./.F.
Objetivos   : Validação dos campos do cadastro de Embarcações
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/09/2002 18:25
Revisao     :
Obs.        :
*/
Function AC170Crit(cCpo)
LOCAL dDATA
Local lRet := .t.
Begin Sequence

   If Select("TRB") == 0   // GFP - 13/03/2013
      //WORK dos detalhes
      AC170CriaTRB()  
      //grava registro no WORK
      AC170GrvTRB()
   EndIf

   If EasyEntryPoint("EECAC170")
      lRet := ExecBlock("EECAC170", .F., .F., cCpo)
      If Empty(cCpo) .or. (ValType(lRet) = "L" .and. !lRet)
         Break
      EndIf
   EndIf

   do Case
      Case cCpo == "EE6_DT_CON"
           IF dDataBase <= M->EE6_DT_CON
              MsgInfo(STR0025,STR0018) //"Dt.Construc. deverá ser menor que a data atual !"
              lRet := .F.
              Break
           Endif
   
      Case cCpo == "EE6_ETAORI"
           IF ! EMPTY(M->EE6_ETAORI)         
              // BUSCA A MENOR DATA DE ETA DESTINO
              dDATA := AVCTOD("")
              TRB->(DBGOTOP())
              DO WHILE ! TRB->(EOF())
                 IF ! EMPTY(TRB->EX8_ETADES) .AND.;
                    (EMPTY(dDATA) .OR. DTOS(TRB->EX8_ETADES) < DTOS(dDATA))
                    *
                    dDATA := TRB->EX8_ETADES
                 ENDIF
                 TRB->(DBSKIP())
              ENDDO                           
              IF ! EMPTY(dDATA) .AND. DTOS(M->EE6_ETAORI) > DTOS(dDATA)
                 MSGINFO(STR0017,STR0018) //"ETA Origem deve ser menor que o ETA Destino !"###"Aviso"
                 lRET := .F.
                 BREAK
              /*
                 Nopado por ER - 05/09/2006.
                 Devido a solicitação de alguns clientes, essa validação foi nopada. Os clientes alegam que
                 uma mercadoria pode ser liberada antes de o navio atracar no Porto de Origem.
                 Um exemplo disso é quando a mercadoria é liberada para ficar no armazém do porto, nesse caso
                 não é necessário que o Navio tenha chegado ao Porto de Origem.
              */
              /*
              ELSEIF ! EMPTY(M->EE6_DEADLI) .AND. DTOS(M->EE6_ETAORI) > DTOS(M->EE6_DEADLI)
                     MSGINFO(STR0019,STR0018) //"ETA Origem não pode ser maior que o Dead Line da Embarcação !"###"Aviso"
                     lRET := .F.
                     BREAK                     
              */
              ELSEIF ! EMPTY(M->EE6_ETSORI) .AND. DTOS(M->EE6_ETAORI) > DTOS(M->EE6_ETSORI)
                     MSGINFO(STR0026,STR0018) //###"Aviso" //"ETA Origem não pode ser maior que o ETD Origem !"
                     lRET := .F.
                     BREAK  
              //LRS - 30/06/2016       
              ELSEIF ! EMPTY(M->EE6_ETADES) .AND. DTOS(M->EE6_ETAORI) > DTOS(M->EE6_ETADES)
                     MSGINFO("ETA Origem não pode ser maior que o ETA Destino !",STR0018) //###"Aviso" //"ETA Origem não pode ser maior que o ETA DESTINO !"
                     lRET := .F.
                     BREAK                          
              ENDIF
           ENDIF
      Case cCpo == "EE6_DEADLI"
           IF ! EMPTY(M->EE6_DEADLI)
              /*
                 Nopado por ER - 05/09/2006.
                 Devido a solicitação de alguns clientes, essa validação foi nopada. Os clientes alegam que
                 uma mercadoria pode ser liberada antes de o navio atracar no Porto de Origem.
                 Um exemplo disso é quando a mercadoria é liberada para ficar no armazém do porto, nesse caso
                 não é necessário que o Navio tenha chegado ao Porto de Origem.
              */
              /*
              IF ! EMPTY(M->EE6_ETAORI) .AND. DTOS(M->EE6_DEADLI) < DTOS(M->EE6_ETAORI)
                 MSGINFO(STR0020,STR0018) //"Dead Line deve ser maior ou igual ao ETA Origem !"###"Aviso"
                 lRET := .F.
                 BREAK           
              ENDIF
              */
              IF !Empty(M->EE6_ETSORI) .AND. M->EE6_DEADLI > M->EE6_ETSORI
                 MsgInfo(STR0027,STR0018) //"Dead Line deve ser menor ou igual ao ETS Origem !"
                 lRet := .f.
                 Break
              Endif              
           ENDIF                 
      Case cCpo == "EE6_ETSORI"
            IF !Empty(M->EE6_ETSORI)
               IF !Empty(M->EE6_DEADLI) .AND. M->EE6_ETSORI < M->EE6_DEADLI
                 MsgInfo(STR0028,STR0018) //"ETS Origem deve ser maior ou igual ao Dead Line !"
                 lRet := .f.
                 Break
               Endif
               IF !Empty(M->EE6_ETAORI) .AND. M->EE6_ETSORI < M->EE6_ETAORI
                 MsgInfo(STR0029,STR0018) //"ETD Origem deve ser maior ou igual ao ETA Origem !"
                 lRet := .f.
                 Break
               Endif
               IF !Empty(M->EE6_ETADES) .AND. M->EE6_ETSORI > M->EE6_ETADES
                 MsgInfo(STR0031,STR0018) //"ETD Origem deve ser menor ou igual ao ETA Destino !"
                 lRet := .f.
                 Break
               Endif
               
               IF ! IsVazio("TRB")
                  nRecOld := TRB->(Recno())
                  TRB->(dbGoTop())
                  IF M->EE6_ETSORI+TRB->EX8_TT_ETA <> TRB->EX8_ETADES
                     lRecalculo := MsgYesNo(STR0024) //"Deseja recalcular o Transit Time da(s) rota(s) de destino ?"
                  Endif
                  TRB->(dbGoTo(nRecOld))

                  IF lRecalculo
                     AC170Recalculo(.T.,M->EE6_COD,M->EE6_VIAGEM)
                     oSelect:oBrowse:Refresh()
                  Endif                  
               Endif
            Endif
                      
      Case cCpo == "EX8_ETADES"   
           //LRS - 30/06/2016 - Nopado para validação na capa              
           /* IF ! EMPTY(M->EX8_ETADES)
               IF ! EMPTY(M->EE6_ETAORI) .AND. DTOS(M->EX8_ETADES) < (DTOS(M->EE6_ETSORI+M->EX8_TT_ETA))
                  MSGINFO(STR0021,STR0018) //"ETA Destino deve ser maior que o ETD Origem !"###"Aviso"
                  lRET := .F.
                  BREAK
               ENDIF                  
            ENDIF   
            IF ! EMPTY(M->EX8_ETADES)
               IF ! EMPTY(M->EE6_ETAORI) .AND. DTOS(M->EX8_ETADES) < (DTOS(M->EE6_ETAORI))
                  MSGINFO(STR0021,STR0018) //"ETA Destino deve ser maior que o ETA Origem !"###"Aviso"
                  lRET := .F.
                  BREAK
               ENDIF                  
            ENDIF*/       
      Case cCpo == "EX8_ETBDES"
            If M->EX8_ETBDES < M->EX8_ETADES+M->EX8_TT_ETB
               MsgInfo(STR0022,STR0018)
               lRET := .F.
               BREAK
            EndIf
      Case cCpo == "EX8_ETSDES"
            If M->EX8_ETSDES < M->EX8_ETBDES
               MsgInfo(STR0023,STR0018)
               lRET := .F.
               BREAK
            EndIf
      
   END CASE
END SEQUENCE
RETURN(lRET)
*----------------------------------------------------------------------
/*
Funcao      : AC170Destino()
Parametros  : cCampo -> Recebe uma string com o nome do campo a ser calculado.
              lWork  -> Calculo com base na work ou na tabela (EX8)
Objetivos   : Apresentar os valores calculados p/ proximo destino.
Autor       : Alexsander Martins dos Santos
Data/Hor
,a   : 27/11/2003 às 14:47.
Aleracao    : Cristiano A. Ferreira
              10/12/2003 15:48
*/
Function AC170Destino(cCampo, lWork)

Local lPortoDestino := .F.
Local lPortoOrigem  := .F.
Local cAlias, nRegTRB, xRetorno, bMudouEmbarc
Local cCod          := EX8->EX8_NAVIO
Local cViagem       := EX8->EX8_VIAGEM
Local nDifETBETS    := 0

Default lWork := .t.

cAlias        := IF(lWork,"TRB","EX8")
nRegTRB       := (cAlias)->(Recno())
bMudouEmbarc  := IF(lWork,{|| TRB->(Eof()) .Or. TRB->(Bof()) },;
                          {|| EX8->(Eof()) .Or. EX8->(Bof()) .Or. EX8->EX8_FILIAL <> xFilial("EX8") .Or.;
                              EX8->EX8_NAVIO <> cCod .Or. EX8->EX8_VIAGEM <> cViagem})


SYR->(dbSetOrder(5))
SYQ->(dbSetOrder(1))

IF Type("lRecalculo") == "U"    
   lRecalculo := .t.
Endif
                            
Begin Sequence
   IF !lWork .And. !lRecalculo
      MsgInfo(STR0030,STR0018) //"Função AC170Destino não pode ser executada com lWork == .F. e lRecalculo == .F. !"###"Aviso"
      Break
   Endif

   // Transite Time.
   If !lRecalculo .and. (cCampo = "EX8_TT_ETA" .or. cCampo = Nil)
      
      IF nOpcDet = 1
         TRB->(dbGoBottom())
         SYR->(dbSeek(xFilial("SYR")+If(TRB->(Eof()), M->EE6_ORIGEM, TRB->EX8_DEST)+M->EX8_DEST))
      Else
         TRB->(dbSkip(-1))
         SYR->(dbSeek(xFilial("SYR")+(If(TRB->(Bof()), M->EE6_ORIGEM, TRB->EX8_DEST))+M->EX8_DEST))
      EndIf

      While SYR->(!Eof() .and. (YR_ORIGEM == (If( TRB->(Bof()), M->EE6_ORIGEM, TRB->EX8_DEST )) .and. YR_DESTINO == M->EX8_DEST))
    
         If SYQ->(dbSeek(xFilial("SYQ")+SYR->YR_VIA) .and. Left(YQ_COD_DI, 1) = "1")
            xRetorno := M->EX8_TT_ETA := SYR->YR_TRANS_T
            lPortoDestino := .T.
            Exit
         EndIf

         lPortoDestino := .F.
         SYR->(dbSkip())

      End

      (cAlias)->(dbGoTo(nRegTRB))

      If !lPortoDestino
         // MsgInfo("O porto de destino informado, não está relacionado com o porto de origem para via Maritima.", "Atenção")
         xRetorno := M->EX8_TT_ETA := 0
         Break
      EndIf   
   EndIf
   
   //ETA Destino
   If cCampo = "EX8_ETADES" .or. cCampo = Nil   
      If nOpcDet = 1
         IF lWork
            (cAlias)->(dbGoBottom())
         Else 
            (cAlias)->(AVSeekLast(xFilial()+cCod+cViagem))
         Endif
      Else
         (cAlias)->(dbSkip(-1))
      EndIf
      
      dETS := AvCtoD("")
      IF Eval(bMudouEmbarc)
         dETS := IF(lWork,IF(Empty(M->EE6_EMBEFE),M->EE6_ETSORI,M->EE6_EMBEFE),IF(Empty(EE6->EE6_EMBEFE),EE6->EE6_ETSORI,EE6->EE6_EMBEFE))
      Else
         dETS := (cAlias)->EX8_ETSDES
      Endif   
      
      (cAlias)->(dbGoTo(nRegTRB))
      
      xRetorno :=  dETS+IF(lRecalculo,(cAlias)->EX8_TT_ETA,M->EX8_TT_ETA)
      
      IF lWork
         IF lRecalculo
            TRB->EX8_ETADES := xRetorno
         Else
            M->EX8_ETADES := xRetorno
         Endif
      Else 
         EX8->EX8_ETADES := xRetorno         
      Endif
   EndIf
   
   //T.T(A/B) Destino
   If !lRecalculo .and. (cCampo = "EX8_TT_ETB" .or. cCampo = Nil)  
      SY9->(dbSetOrder(2))
      SY9->(dbseek(XFILIAL("SY9")+M->EX8_DEST))

      xRetorno := M->EX8_TT_ETB := SY9->Y9_TT_ETS
   EndIf
   
   //ETB Destino
   If cCampo = "EX8_ETBDES" .or. cCampo = Nil   
      nDifETBETS := IF(lRecalculo,(cAlias)->EX8_ETSDES-(cAlias)->EX8_ETBDES,M->EX8_ETSDES-M->EX8_ETBDES)
      
      IF !lRecalculo .And. ReadVar() == "M->EX8_ETBDES"
         nDifETBETS := M->EX8_ETSDES-(M->EX8_ETADES+M->EX8_TT_ETB)
      Endif
  
      xRetorno := IF(lRecalculo,(cAlias)->EX8_ETADES+(cAlias)->EX8_TT_ETB,M->EX8_ETADES+M->EX8_TT_ETB)
     
      IF lWork      
         IF lRecalculo
            TRB->EX8_ETBDES := xRetorno
            TRB->EX8_ETSDES := TRB->EX8_ETBDES+nDifETBETS
         Else
            M->EX8_ETBDES := xRetorno
            M->EX8_ETSDES := M->EX8_ETBDES+nDifETBETS
         Endif
      Else
         EX8->EX8_ETBDES := xRetorno
         EX8->EX8_ETSDES := EX8->EX8_ETBDES+nDifETBETS
      Endif          
   EndIf  

End Sequence

lRecalculo := .F.

Return(xRetorno)

/*
Funcao      : AC170Recalculo
Parametros  : lWork   => Calculo com base na Work ou na tabela (EX8)
              cCod    => Codigo da Embarcacao
              cViagem => Nro. da Viagem
Objetivos   : Recalcular as data de destino da embarcacao (ETA,ETS,ETB)
Autor       : Cristiano A. Ferreira
Data/Hora   : 10/12/2003 15:00
*/
Function AC170Recalculo(lWork,cCod,cViagem)

Local cAlias := IF(lWork,"TRB","EX8")
Local bWhile := IF(lWork,{||.t.},{|| EX8->EX8_FILIAL == xFilial("EX8") .And. EX8->EX8_NAVIO == cCod .And. EX8->EX8_VIAGEM == cViagem})
Local aKey := {}, dOldETADes, i
Local nRecOld := (cAlias)->(RecNo())
Local aOrd := SaveOrd(cAlias)

Private nOpcDet := 2  // apenas para funcao AC170Destino

IF lWork
   (cAlias)->(dbGoTop())
Else 
   (cAlias)->(dbSetOrder(3))
   (cAlias)->(dbSeek(xFilial()+cCod+cViagem))
Endif

While ! (cAlias)->(Eof()) .And. Eval(bWhile)
   
   //Recalculo do Transit Time das rotas de destino.
   (cAlias)->(RecLock(cAlias,.F.))
		     
   lRecalculo := .t.
   dOldETADes := (cAlias)->EX8_ETADES // Salvar ETA original
   AC170Destino(,lWork)
   aAdd(aKey,{(cAlias)->(Recno()),(cAlias)->EX8_ETADES})
   (cAlias)->EX8_ETADES := dOldETADes
	
   //Final do Recalculo.
   (cAlias)->(MsUnlock())

   (cAlias)->(dbSkip())
Enddo

// atualizar a chave
For i:=1 To Len(aKey)
   (cAlias)->(dbGoTo(aKey[i][1]))
   (cAlias)->(RecLock(cAlias,.F.))
   (cAlias)->EX8_ETADES := aKey[i][2]   
   (cAlias)->(MsUnlock())
Next

RestOrd(aOrd)
(cAlias)->(dbGoTo(nRecOld))
   
Return NIL

/*
Funcao      : AC170AtuCpo
Parametros  : cCpo    => Campo a ser recalculado / atualizado
Objetivos   : Atualizar / Recalcular campos nos gatilhos
Autor       : Cristiano A. Ferreira
Data/Hora   : 18/12/2003 10:38
*/
Function AC170AtuCpo(cCpo)

Local xRet, dETS
Local nRecno := 0

Begin Sequence
   do Case 
      Case cCpo == "EX8_TT_ETA"
         xRet   := 0             
         nRecno := TRB->(RecNo())
         
         IF Type("lIncDet") == "L" .And. lIncDet
            TRB->(dbGoBottom()) // qdo eh inclusao 
         Else
            TRB->(dbSkip(-1))
         Endif
         IF TRB->(Eof() .Or. Bof())
            dETS := M->EE6_ETSORI 
         Else
            dETS := TRB->EX8_ETSDES
         Endif
         
         TRB->(dbGoTo(nRecno))
         
         xRet := If(!Empty(M->EX8_ETADES).and.!Empty(dETS),M->EX8_ETADES - dETS,0)                
                   
      Case cCpo == "EX8_TT_ETB"
         xRet := M->EX8_ETBDES - M->EX8_ETADES

      Case cCpo == "EX8_ETSDES"      
         nDifETBETS := M->EX8_ETSDES-(M->EX8_ETADES+M->EX8_TT_ETB)  
         xRet := M->EX8_ETSDES := M->EX8_ETBDES+nDifETBETS
         
   End Case

End Sequence

Return xRet

Function AC170AtuNavio(cOrigem)
Default cOrigem := ""

   Do Case
      Case cOrigem == "NAVIO"
         cNavio		:= EE6->EE6_COD
         cViagem	:= EE6->EE6_VIAGEM
         cOrigem	:= EE6->EE6_ORIGEM
         dETA		:= EE6->EE6_ETAORI
         cETAHR		:= EE6->EE6_ETAHR
         dETB		:= EE6->EE6_ETB
         cETBHR		:= EE6->EE6_ETBHR
         dETD		:= EE6->EE6_ETSORI
         cETDHR		:= EE6->EE6_ETDHR
         dDraft		:= EE6->EE6_DLDRAF
         cDraftHr	:= EE6->EE6_DLDRHR
         dCarga		:= EE6->EE6_DEADLI
         cCargaHr	:= EE6->EE6_DLCAHR
         
         AtuEmbarque(cOrigem)

      Case cOrigem == "DESTINOS"
         ChkFile("EX8")//Nem sempre esta tabela está aberta.
         cNavio		:= EX8->EX8_NAVIO
         cViagem	:= EX8->EX8_VIAGEM
         cOrigem	:= EX8->EX8_DEST
         dETA		:= EX8->EX8_ETADES
         cETAHR		:= EX8->EX8_ETAHR
         dETB		:= EX8->EX8_ETBDES
         cETBHR		:= EX8->EX8_ETBHR
         dETD		:= EX8->EX8_ETSDES
         cETDHR		:= EX8->EX8_ETDHR
         dDraft		:= EX8->EX8_DLDRAF
         cDraftHr	:= EX8->EX8_DLDRHR
         dCarga		:= EX8->EX8_DLCARGA
         cCargaHr	:= EX8->EX8_DLCAHR
         
         AtuEmbarque(cOrigem)
      
      Case cOrigem == "EMBARQUE"
         cNavio		:= EEC->EEC_EMBARC
         cViagem	:= EEC->EEC_VIAGEM
         cOrigem	:= EEC->EEC_ORIGEM
         dETA		:= EEC->EEC_ETA
         cETAHR		:= EEC->EEC_ETAHR
         dETB		:= EEC->EEC_ETB
         cETBHR		:= EEC->EEC_ETBHR
         dETD		:= EEC->EEC_ETD
         cETDHR		:= EEC->EEC_ETDHR
         dDraft		:= EEC->EEC_DLDRAF
         cDraftHr	:= EEC->EEC_DLDRHR
         dCarga		:= EEC->EEC_DLCARGA
         cCargaHr	:= EEC->EEC_DLCAHR
         
   End Case

Return Nil

Static Function AtuEmbarque(cOrigem)
Local aOrd := SaveOrd("EEC")

   EEC->(DbSetOrder(16))
   EEC->(DbSeek(xFilial()+cNavio+cViagem+cOrigem))
   While EEC->(!Eof() .And. EEC_FILIAL+EEC_EMBARC+EEC_VIAGEM+EEC_ORIGEM == xFilial()+cNavio+cViagem+cOrigem)

         EEC->(RecLock("EEC", .F.))
         EEC->EEC_ETA	 	:= dETA
         EEC->EEC_ETAHR 	:= cETAHR
         EEC->EEC_ETB 		:= dETB
         EEC->EEC_ETBHR 	:= cETBHR
         EEC->EEC_ETD	 	:= dETD
         EEC->EEC_ETDHR 	:= cETDHR
         EEC->EEC_DLDRAF 	:= dDraft
         EEC->EEC_DLDRHR 	:= cDraftHr
         EEC->EEC_DLCARGA 	:= dCarga
         EEC->EEC_DLCAHR 	:= cCargaHr
         EEC->(MsUnlock())
      
      EEC->(DbSkip())
   EndDo

RestOrd(aOrd)
Return Nil

/*
Programa   : AC170CriaTRB
Objetivo   : Criação da work TRB
Retorno    : Nil
Autor      : Guilherme Fernandes Pilan
Data/Hora  : 13/03/2013
*/
*-------------------------*
Function AC170CriaTRB()
*-------------------------*
aCampos:= Array(EX8->(FCount()))
aSemSx3 := {}
Aadd( aSemSx3, { "RECNO", "N", 10, 0 })
//TRP - 26/01/07 - Campos do WalkThru
AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
cNomArq:=E_CriaTrab("EX8",aSemSx3,"TRB")
//IndRegua("TRB",cNomArq+OrdBagExt(),"EX8_DEST")
IndRegua("TRB",cNomArq+TEOrdBagExt(),"EX8_ETADES")
   
Return