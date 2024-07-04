#INCLUDE "EECAE103.ch"
#INCLUDE "EEC.cH"

/*
Programa        : EECAE103.PRW
Objetivo        : Cadastro de Containers
Autor           : Ricardo Dumbrovsky
Data/Hora       : 07/30/02 14:30
Obs.            :
*/            
    

/*
********************
FUNCTION EECAE103()
********************

AE103MAN("EX9")
    
Return NIL
*/

/*
Funcao      : AE103MAN
Retorno     : NIL
Objetivos   : Manutencao da tabela de containers
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/30/2002 14:37
Revisao     :
Obs.        :
*/                             

/*
Function AE103MAN(cAlias)

Local nInc, aButtons := {}
Local nOpcA := 0, nReg := EEC->( Recno() )
Local bOk , bCancel := {|| oDlg:End() }
Local aPos,  oDlg
Local aSelectFields := {{"EX9_CONTNR",AVSX3("EX9_CONTNR",6),STR0001},;  //"No.Container"
                        {"EX9_LACRE",AVSX3("EX9_LACRE",6),STR0002},;   //"Lacre"
                        {{|| Transf(TRB->EX9_TARA,AVSX3("EX9_TARA",6))},"",STR0003}}  //"Tara"

Private aCampos :={}, aGets[0], aTela[0], aObjs[4], aDeletados := {}
Private aMemos:={{"EX9_OBS","EX9_VM_OBS"}}
Private aDelContainer:={}
              
Begin Sequence

      Neste ponto o sistema irá verificar se o embarque já foi finalizado, se o usuário 
      selecionou um registro da filial de off-shore, ou se o usuário está logado na filial
      de off-shore. Em qq um dos  casos o sistema irá exibir uma msg de alerta ao usuário 
      e posteriormente irá  disponibilizar apenas a opção de visualização de containers 

   If !Empty(EEC->EEC_DTEMBA)
      MsgInfo( STR0009, STR0007 ) //"Embarque finalizado."###"Atenção"
      aAdd(aButtons,{"ANALITICO",{|| AE103Det(VIS_DET, oSelect)},"Visualizar"})
   
   ElseIf lIntermed .And. EEC->EEC_FILIAL <> cFilBr
      MsgInfo("Inclusões/Alterações/Exclusões deverão ser realizadas apenas na filial Brasil.","Atenção")
      aAdd(aButtons,{"ANALITICO",{|| AE103Det(VIS_DET, oSelect)},"Visualizar"})
         
   Else
      aAdd(aButtons,{"ANALITICO",{|| AE103Det(VIS_DET, oSelect)},"Visualizar"})
      aAdd(aButtons,{"EDIT"     ,{|| AE103Det(INC_DET, oSelect)},"Incluir"})
      aAdd(aButtons,{"ALT_CAD"  ,{|| AE103Det(ALT_DET, oSelect)},"Alterar"})
      aAdd(aButtons,{"EXCLUIR"  ,{|| AE103Det(EXC_DET, oSelect)},"Excluir"})
   EndIf

   M->EEC_PREEMB := EEC->EEC_PREEMB
   M->EEC_IMPORT := EEC->EEC_IMPORT
   M->EEC_IMPODE := EEC->EEC_IMPODE
   M->EEC_STTDES := EEC->EEC_STTDES
   bOk := {|| nOpcA:=1, IF(AE103Valid(3),oDlg:End(),nOpcA:=0)}

   //WORK dos detalhes
   aCampos:= Array(EX9->(FCount()))
   aSemSx3 := {}
   Aadd( aSemSx3, { "RECNO", "N", 10, 0 })
   cNomArq:=E_CriaTrab("EX9",aSemSx3,"TRB")
   //MFR 18/12/2018 OSSME-1974
   IndRegua("TRB",cNomArq+TeOrdBagExt(),"EX9_CONTNR")

   //grava registro no WORK
   AE103GrvTRB()

   If lIntermed
      If IsVazio("TRB") .And. EEC->EEC_FILIAL <> cFilBr
         MsgStop("Não existe container cadastrado para o processo.","Atenção")
         lRet:=.f.
         Break
      EndIf
   EndIf

   TRB->(dbGoTop())
   nOpcA := 0 
   nOpc  := 2
   
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
   
      @ 18,03  SAY AVSX3("EEC_PREEMB",AV_TITULO) PIXEL OF oDlg
      @ 18,180 SAY AVSX3("EEC_IMPORT",AV_TITULO) PIXEL OF oDlg
      @ 29,03  SAY AVSX3("EEC_IMPODE",AV_TITULO) PIXEL OF oDlg
      @ 40,03  SAY AVSX3("EEC_STTDES",AV_TITULO) PIXEL OF oDlg
      
      @ 18,40  MSGET aObjs[1] VAR M->EEC_PREEMB  PICTURE AVSX3("EEC_PREEMB",AV_PICTURE) PIXEL OF oDlg ;
               WHEN .F. SIZE 3.5*AVSX3("EEC_PREEMB",AV_TAMANHO),08 
      @ 18,220 MSGET aObjs[2] VAR M->EEC_IMPORT  PICTURE AVSX3("EEC_IMPORT",AV_PICTURE) PIXEL OF oDlg ;
               WHEN .F. SIZE 4.5*AVSX3("EEC_IMPORT",AV_TAMANHO),08 
      @ 29,40  MSGET aObjs[3] VAR M->EEC_IMPODE  PICTURE AVSX3("EEC_IMPODE",AV_PICTURE) PIXEL OF oDlg ;
               WHEN .F. SIZE 3.5*AVSX3("EEC_IMPODE",AV_TAMANHO),08
      @ 40,40  MSGET aObjs[4] VAR M->EEC_STTDES  PICTURE AVSX3("EEC_STTDES",AV_PICTURE) PIXEL OF oDlg ;
               WHEN .F. SIZE 4.5*AVSX3("EEC_STTDES",AV_TAMANHO),08
                    
      oSelect := MsSelect():New("TRB",,,aSelectFields,,,PosDlgDown(oDLG))
      oSelect:bAval := {|| AE103Det(VIS_DET,oSelect) }
      
  ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons)) CENTERED
   
   If nOpcA == 1
      Begin Transaction
         Processa({|| AE103Grava(nReg), Ae103SetOffShore()})
         //Processa Gatilhos
         EvalTrigger()
         If __lSX8
            ConfirmSX8()
         Endif
      End Transaction
   Elseif nOpcA == 2 
      Begin Transaction       
         EX9->(dbSeek(xFilial()+EEC->EEC_PREEMB))
         While EX9->( !Eof() ) .And. EX9->(EX9_FILIAL+EX9_PREEMB)  == EEC->(EEC_FILIAL+EEC_PREEMB)
            MSMM(EX9->EX9_OBS,,,,EXCMEMO)
            EX9->(RecLock("EX9",.F.))
            EX9->(dbDelete())
            EX9->(MSUNLOCK())
            EX9->(dbSkip())
         Enddo
        
      End Transaction
   Elseif nOpcA == 0
      If __lSX8
         RollBackSX8()
      Endif
   Endif
   
End Sequence

If Select("TRB") > 0
   TRB->(E_EraseArq(cNomArq))
EndIf

Return NIL
*/

/*
Funcao      : AE103GrvTRB
Parametros  : nenhum
Retorno     : .T./.F.
Objetivos   : Grava Destinos
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/25/2002 13:10
Revisao     :
Obs.        :
*/                   
/*
***************************
STATIC Function AE103GrvTRB
***************************

EX9->(dbSeek(xFilial()+M->EEC_PREEMB ))
DO While EX9->(!Eof()) .And. EX9->(EX9_FILIAL+EX9_PREEMB) == (XFILIAL("EEC")+M->EEC_PREEMB)
   TRB->(dbAppend())
   TRB->RECNO := EX9->(RecNo())
   AVREPLACE("EX9","TRB")
   
   TRB->EX9_VM_OBS := MSMM(EX9->EX9_OBS,AVSX3("EX9_VM_OBS")[AV_TAMANHO])
   
   EX9->(dbSkip())
Enddo
Return (TRB->(LastRec()) != 0)
  */
/*
Funcao      : AE103Grava
Parametros  : cAlias := alias arq.
              nReg   := num.registro
              nOpc   := opcao escolhida
Retorno     : .T. 
Objetivos   : Grava Containers do Processo
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/30/2002 13:15
Revisao     :
Obs.        :
*/
/*
********************************
STATIC Function AE103Grava(nReg)
********************************
LOCAL i
Local lRet := .t.

ProcRegua(TRB->(LastRec())+1)

IncProc(STR0004) //"Atualizando arquivos ..."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo EX9 (Containers)                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TRB->(dbGoTop())
 
While ! TRB->(Eof()) 
   IncProc()

   IF TRB->RECNO == 0
      EX9->(RecLock("EX9",.T.))
      EX9->EX9_FILIAL := xFilial("EX9")
      EX9->EX9_PREEMB := EEC->EEC_PREEMB
   Else
      EX9->(dbGoTo(TRB->RECNO))
      EX9->(RecLock("EX9",.F.))
   Endif
   AVREPLACE("TRB","EX9")   
 
   IF TRB->RECNO <> 0
      MSMM(EX9->EX9_OBS,,,,EXCMEMO)
   Endif
   
   EX9->(MSMM(EX9->EX9_OBS,AVSX3("EX9_VM_OBS",AV_TAMANHO),,TRB->EX9_VM_OBS,INCMEMO,,,"EX9","EX9_OBS"))
   
   EX9->(MSUnlock())
   TRB->(dbSkip())
Enddo

For i:=1 To Len(aDeletados)
   IncProc()
   EX9->(dbGoTo(aDeletados[i]))
   aAdd(aDelContainer,EX9->EX9_CONTNR)
   MSMM(EX9->EX9_OBS,,,,EXCMEMO)
   EX9->(RecLock("EX9",.F.))
   EX9->(dbDelete())
   EX9->(MSUnlock())
Next i

Return lRet
*/

/*-------------------------------------------------------------------
Funcao      : AE103Det
Parametros  : nOpc := 2 // Visualizacao
                      3 // Inclusao
                      4 // Alteracao
                      5 // Exclusao
Retorno     : NIL
Objetivos   : Manutencao dos cONTAINERS
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/30/2002 15:20
Revisao     :
Obs.        :
*/
/*
***************************************
STATIC Function AE103Det(nOpc, oSelect)
***************************************
Local nAreaOld := Select() 
LOCAL oDlg, nOpcA:=0
LOCAL nInc
LOCAL nReg

LOCAL bOk     := {||nOpcA:=1,IF(AE103ValDet(nOpc,nReg),oDlg:End(),nOpcA=0)}
LOCAL bCancel := {|| oDlg:End()}

Private aTela[0][0],aGets[0],nUsado:=0
Private cContainer := ""

Begin Sequence
   IF nOpc != INC_DET .And. TRB->(EOF()) .AND. TRB->(BOF())
      HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
      Break
   EndIf
        
   nReg := TRB->(RecNo())
        
   For nInc := 1 TO TRB->(FCount())
      IF AllTrim(TRB->(FieldName(nInc))) $ "DELETE,RECNO"
         Loop
      Endif
      
      IF nOpc == INC_DET // Inclusao
         TRB->(M->&(FIELDNAME(nInc)) := CriaVar(FieldName(nInc)))
      Else
         TRB->(M->&(FIELDNAME(nInc)) := TRB->(FIELDGET(nInc)))
      Endif
   Next nInc
   
   If nOpc == INC_DET // INCLUIR       
      M->EX9_PREEMB := M->EEC_PREEMB
      M->EX9_VM_OBS := ""
      M->EX9_OBS    := ""
   Else
      cContainer := M->EX9_CONTNR
   EndIf

   While .T.
      nOpcA := 0
      aTela := {}
      aGets := {}
      DEFINE MSDIALOG oDlg TITLE STR0005+M->EEC_PREEMB FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL  //"Containers para o Processo => "
         EnChoice("EX9", , 3, , , , , PosDlg(oDLG), IF(STR(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},), 3)
      ACTIVATE MSDIALOG oDlg ON INIT AvBar(nOpc,oDlg,bOk,bCancel)
      IF nOpcA == 1 // Ok
         IF nOpc == INC_DET
            TRB->(DBAPPEND())
            nReg := TRB->(RecNo())
         Endif
               
         IF ! Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
            TRB->(DBGOTO(nReg))
            
            For nInc:= 1 TO TRB->(FCount())
               IF AllTrim(TRB->(FieldName(nInc))) $ "RECNO,DELETE"
                  Loop
               Endif
               TRB->(FieldPut(nInc,M->&(FIELDNAME(nInc))))
            Next
         EndIF
         
         oSelect:oBrowse:Refresh()
         
         Exit
      Elseif nOpcA == 0 // Cancel
         Exit
      Endif
   Enddo
End Sequence

Select(nAreaOld) // CAF - 27/04/2000 - Enchoice muda a area corrente

Return NIL                           
*/

/*
Funcao      : AE103Valid(nOpc)
Parametros  : nOpc := 2 - Visualizacao
                      3 - Inclusao
                      4 - Alteracao
                      5 - Exclusao
Retorno     : .T./.F.
Objetivos   : Consistencias do EX9
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/30/2002 15:25
Revisao     :
Obs.        :
*/
/*
********************************
Static Function AE103Valid(nOpc)
********************************
LOCAL lRet := .T.
Begin Sequence
   IF Str(nOpc,1) $ Str(INCLUIR,1)+"/"+Str(ALTERAR,1)
      IF ! Obrigatorio(aGets,aTela)
         lRet := .F.
         Break
      Endif
      TRB->(dbGoTop())
      
      //CAF 04/01/05 - Não deve obrigar registros de Containeres 
      //IF TRB->(Eof() .And. Bof()) 
      //   HELP(" ",1,"AVG0005019") //MsgStop("Não existem Tarifas de Fretes cadastradas !","Atenção")
      //   lRet:=.F.
      //   Break
      //Endif
      
   Elseif nOpc == EXCLUIR
      IF ! MsgNoYes(STR0006,STR0007) //"Confirma a Exclusão ?"###"Atenção"
         lRet := .F.
         Break 
      Endif
   Endif
End Sequence
Return lRet
*/

/*
Funcao      : AE103ValDet
Parametros  : nOpc   := 2 // Visualizacao
                        3 // Inclusao
                        4 // Alteracao
                        5 // Exclusao
              nReg   := Numero do Registro
              cCampo := Nome do campo.
Retorno     : .T./.F.
Objetivos   : Consistencias dos Containers
Autor       : Ricardo Dumbrovsky
Data/Hora   : 07/30/2002 15:30
Revisao     :
Obs.        :
*/
/*
STATIC Function AE103ValDet(nOpc, nReg, cCampo)
LOCAL lRet := .T.
Begin Sequence
   
   Do Case
      Case cCampo == "EX9_CONTNR"
         If cContainer <> M->EX9_CONTNR .and. TRB->(dbSeek(M->EX9_CONTNR))
            MsgStop( STR0010, STR0007 ) //"Nº do Container já cadastrado"###"Atenção"
            lRet := .F.
         EndIf
         Break         
   EndCase

   IF Str(nOpc,1) $ Str(INC_DET,1)+"/"+Str(ALT_DET,1)
      IF ! Obrigatorio(aGets,aTela)
         lRet := .F.
         Break
      Endif
   Elseif nOpc == EXC_DET
      IF MsgNoYes(STR0008) //"Confirma exclusão do Registro Atual ? "
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

Return lRet
*/

Function AE103ValDet()
Local aOrd, lRet := .T.
Local nRecno := 0

Begin Sequence
   
   If ReadVar() = "M->EX9_CONTNR"
      If nSelecao = INCLUIR
         aOrd := SaveOrd("EX9")
         If !(lRet := ExistChav("EX9",EEC->EEC_PREEMB+M->EX9_CONTNR))
            Break
         EndIf
      EndIf
      
      If EECFlags("ESTUFAGEM")
         If nSelecao <> INCLUIR
            nRecno := (cWorkEX9)->(Recno())
         EndIf
         If (cWorkEX9)->(DbSeek(M->EX9_CONTNR))
            If (nSelecao == INCLUIR) .Or. (nRecno == (cWorkEX9)->(Recno()))
               MsgInfo(STR0014, STR0015)//STR0014	"Registro já existente" //STR0015	"Aviso"
               If nSelecao <> INCLUIR
                  (cWorkEX9)->(DbGoTo(nRecno))
               EndIf
               lRet := .F.
               Break
            EndIf
         EndIf
         If nSelecao <> INCLUIR
            (cWorkEX9)->(DbGoTo(nRecno))
         EndIf
      EndIf

   EndIf

End Sequence

If ValType(aOrd) <> "U"
   RestOrd(aOrd,.T.)
EndIf

Return lRet

/*
Funcao      : AE103ContNr
Parametros  : nenhum
Retorno     : .T./.F.
Objetivos   : Inicializacao EX9_CONTNR - função para corrigir problema de função inexistente
              Chamada no SX3.
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*/

Function AE103ContNr

Local cRet := Space(Len(EX9->EX9_CONTNR))

Begin Sequence
   // definições da função.   
End Sequence

Return cRet

/*
Funcao      : AE103ValGet
Parametros  : nenhum
Retorno     : .T./.F.
Objetivos   : When EX9_CONTNR - função para corrigir problema de função inexistente
              Chamada no SX3.
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*/
Function AE103ValGet

Local lRet := .t.

Begin Sequence
   // definições da função.   
End Sequence

Return lRet

/*
Funcao      : Ae103SetOffShore.
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : a) Para os ambientes que possuam a rotina de off-shore habilitada, o sistema irá 
                 automaticamente atualizar a filial de off-shore. 
              b) Para os ambientes que possuam os tratamentos de Multi Off-Shore, o sistema irá
                 automaticamente atualizar todos os níveis de off-shore.
Autor       : Jeferson Barros Jr. 
Data/Hora   : 31/03/05 - 13:49
Obs.        :
*/
/*
*--------------------------------*
Static Function Ae103SetOffShore()
*--------------------------------*
Local lRet:=.t., aEmbarques := {}

Begin Sequence

   If EEC->EEC_FILIAL <> cFilBr
      lRet:=.f.
      Break
   EndIf
   
   // Carrega todos os embarque onde os containers deverão ser atualizados.
   aEmbarques := LoadOffShore()

   If Len(aEmbarques) > 0
      Processa({|| ProcRegua(Len(aEmbarques)),;
                   Ae103UpdateOffShore(aEmbarques)},"Atualizando processo(s) de Off-Shore...")
   Endif

End Sequence

Return lRet
*/
/*
Funcao      : Ae103UpdateOffShore
Parametros  : aEmbarques - Array com os embarques a serem atualizados.
Retorno     : .t./.f.
Objetivos   : a) Para os ambientes que possuam a rotina de off-shore habilitada, o sistema irá 
                 automaticamente atualizar a filial de off-shore. 
              b) Para os ambientes que possuam os tratamentos de Multi Off-Shore, o sistema irá
                 automaticamente atualizar todos os níveis de off-shore.
Autor       : Jeferson Barros Jr. 
Data/Hora   : 31/03/05 - 13:49
Obs.        :
*/
/*
*---------------------------------------------*
Static Function Ae103UpdateOffShore(aEmbarques)
*---------------------------------------------*
Local aOrd := SaveOrd({"EEC","EX9"}), aContainer := {}, aOrdAux:={}
Local lRet := .t., lAdd := .f.
Local j:=0, z:=0, y:=0

Begin Sequence

   // ** Verifica se o sistema possui a rotina de off-shore habilitada.
   If !lIntermed
      lRet:=.f.
      Break
   EndIf

   // ** Verifica se o processo possui tratamentos de off-shore.
   If EEC->EEC_INTERM $ cNao
      lRet:=.f.
      Break
   EndIf

   /* Carrega os containers da filial brasil para futura atualização da filial
      de off-shore. */
   
   /*
   EX9->(DbSetOrder(1))
   If EX9->(DbSeek(cFilBr+EEC->EEC_PREEMB))
      Do While EX9->(!Eof()) .And. EX9->EX9_FILIAL == cFilBr .And.;
                                   EX9->EX9_PREEMB == EEC->EEC_PREEMB
         aAdd(aContainer,EX9->(RecNo()))
         EX9->(DbSkip())
      EndDo
   EndIf

   For y:=1 To Len(aEmbarques)
      IncProc(AllTrim(AvSx3("EEC_PREEMB",AV_TITULO))+": "+aEmbarques[y])

      For j:=1 To Len(aContainer)
         EX9->(DbGoTo(aContainer[j]))

         For z := 1 TO EX9->(FCount())
            M->&(EX9->(FieldName(z))) := EX9->(FieldGet(z))
         Next
         M->EX9_VM_OBS := Msmm(EX9->EX9_OBS,AvSx3("EX9_VM_OBS",AV_TAMANHO))

         lAdd := !EX9->(DbSeek(cFilEx+aEmbarques[y]+EX9->EX9_CONTNR))
         EX9->(RecLock("EX9",lAdd))
         
         If !lAdd
            MSMM(EX9->EX9_OBS,,,,EXCMEMO)
         EndIf

         AvReplace("M","EX9")
         EX9->EX9_FILIAL := cFilEx
         EX9->EX9_PREEMB := aEmbarques[y]
         EX9->EX9_OBS    := ""
         EX9->(Msmm(EX9->EX9_OBS,AvSx3("EX9_VM_OBS",AV_TAMANHO),,M->EX9_VM_OBS,INCMEMO,,,"EX9","EX9_OBS"))
         EX9->(MSUnlock())
      Next

      For j:=1 To Len(aDelContainer)
         For y:=1 To Len(aEmbarques)
            If EX9->(DbSeek(cFilEx+aEmbarques[y]+aDelContainer[j]))
               MSMM(EX9->EX9_OBS,,,,EXCMEMO)
               EX9->(RecLock("EX9",.F.))
               EX9->(dbDelete())
               EX9->(MSUnlock())
            EndIf
         Next
      Next
   Next

End Sequence

RestOrd(aOrd,.t.)

Return lRet
*/

********************************************************************************************************************
*                                              FIM DO PROGRAMA EECAE103                                            *
********************************************************************************************************************
