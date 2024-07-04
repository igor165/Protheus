#INCLUDE "EECCV100.ch"  
#include "EEC.cH"

/*
Programa        : EECCV100
Objetivo        : Manutencao de Vias de Transporte
Autor           : Cristiano A. Ferreira
Data/Hora       : 14/07/1999 11:32
Obs.            : 
*/
Function EECCV100(xAutoCab,xAutoItens,xOpcAuto)
LOCAL aORD:=SAVEORD({"SYQ","SYR"})
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := AVTITCAD("SYQ")

Private lSYQAuto := ValType(xAutoCab) == "A"
Private aSYQAuto := xAutoCab
Private aSYRAuto := xAutoItens
Private nOpcAuto := xOpcAuto

If lSYQAuto .And. Type("lMsErroAuto") <> "L"
    Private lMsErroAuto := .F.
EndIf

If lSYQAuto
    if AvKeyAuto(aSYQAuto)
        MBrowseAuto(nOpcAuto, aSYQAuto, "SYQ",, .T.)
    else
        EasyHelp(STR0037,STR0028) //"Erro na estrutura de array do cabeçalho para integração automática!" , ATENÇÃO
    Endif
Else
    mBrowse( 6, 1,22,75,"SYQ")
endif

RESTORD(aORD,.T.)
Return .T.
                            

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 22/01/07 - 17:28
*/
Static Function MenuDef()
Local aRotAdic := {}         
Local aRotina :=  { {STR0001 ,"AxPesqui"     , 0, PESQUISAR},; //"Pesquisar"
                    {STR0002 ,"EECCV100Manut", 0, VISUALIZAR},; //"Visualizar"
                    {STR0003 ,"EECCV100Manut", 0, INCLUIR},; //"Incluir"
                    {STR0004 ,"EECCV100Manut", 0, ALTERAR},; //"Alterar"
                    {STR0005 ,"EECCV100Manut", 0, EXCLUIR},; //"Excluir"
                    {STR0033 ,"CV200REL"     , 0, 2}} //"Relatorio"
                    
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("ECV100MNU")
	  aRotAdic := ExecBlock("ECV100MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf

Return aRotina

/*
Funcao      : EECCV100Manut
Parametros  : cAlias := alias arq.
              nReg   := num.registro
              nOpc   := opcao escolhida
Retorno     : NIL
Objetivos   : Chamar as funcoes estaticas para manutencao
Autor       : Cristiano A. Ferreira
Data/Hora   : 11/03/2000 11:45
Revisao     :
Obs.        :
*/
Function EECCV100Manut(cAlias,nReg,nOpc)
LOCAL bTransp,nOpcA := 0
LOCAL oDlg
LOCAL cNomArq, cNomArq2, cNomArq3
LOCAL i, nInc:=0, j:=0
LOCAL oSelect
LOCAL bOk,bCancel := {|| oDlg:End() }
LOCAL aBOTAO := {{"PESQUISA" /*"BMPCONS"*/,{|| CV100PESQ(),oSelect:oBrowse:Refresh()},STR0019,STR0001}} //"Pesquisa Oorigem / destino" , "Pesquisar"
Local aWorks:={{"TRB","cNomArq"},{"WorkAg","cNomArq2"},{"WorkFre","cNomArq3"}}
Local cEraseTmp //THTS - 10/10/2017
PRIVATE aTELA[0][0],aGETS[0],nUsado:=0,LEXEEC := .T.
PRIVATE aSemSX3:={}

bTransp := {|| IF(!EMPTY(TRB->YR_TIPTRAN),BSCXBOX("YR_TIPTRAN",TRB->YR_TIPTRAN)," ")}
PRIVATE aSelectFields := { {{||TRB->YR_ORIGEM},,AVSX3("YR_ORIGEM",AV_TITULO) },;
                           {{||TRB->YR_DESTINO},,AVSX3("YR_DESTINO",AV_TITULO)},;
                           {bTransp    ,,AVSX3("YR_TIPTRAN",AV_TITULO)},;
                           ;//{{||TRB->YR_MOEDA} ,,AVSX3("YR_MOEDA",AV_TITULO)  },;
                           {{||TRB->YR_TRANS_T},,AVSX3("YR_TRANS_T",AV_TITULO)},;
                           {{||TRB->YR_PAIS_DE},,AVSX3("YR_PAIS_DE",AV_TITULO)},;
                           {{||TRB->YR_CID_DES},,AVSX3("YR_CID_DES",AV_TITULO)}}

aSelectFields:= AddCpoUser(aSelectFields,"SYR","2")

Private aEnchoice:={"YR_ORIGEM","YR_DESTINO","YR_TIPTRAN","YR_TRANS_T",;
                     "YR_PAIS_DE","YR_CID_DES"}

PRIVATE aHeader[0],aCampos,aDeletados := {},lMoeda := .T.
PRIVATE cORIGEM,cDESTINO,cCIDADED
Private aFreDeletados:={}, aAgDeletados:={}
Private lVisual := (nOpc == VISUALIZAR)
Private cOldOrigem, cOldDestino

cORIGEM  := SPACE(AVSX3("YR_ORIGEM" ,AV_TAMANHO))
cDESTINO := SPACE(AVSX3("YR_DESTINO",AV_TAMANHO))
cCIDADED := SPACE(AVSX3("YR_CID_DES",AV_TAMANHO))
Begin Sequence                        
   // By JPP - 20/06/2005 - 11:30
   AddNaoUsado(aSemSx3,"YR_CONTEIN")  
   AddNaoUsado(aSemSx3,"YR_FRETE_K")
   AddNaoUsado(aSemSx3,"YR_VL_MIN") 
   AddNaoUsado(aSemSx3,"YR_KILO1") 
   AddNaoUsado(aSemSx3,"YR_VALOR1")
   AddNaoUsado(aSemSx3,"YR_KILO2")
   AddNaoUsado(aSemSx3,"YR_VALOR2")
   AddNaoUsado(aSemSx3,"YR_KILO3") 
   AddNaoUsado(aSemSx3,"YR_VALOR3")
   AddNaoUsado(aSemSx3,"YR_KILO4")
   AddNaoUsado(aSemSx3,"YR_VALOR4") 
   AddNaoUsado(aSemSx3,"YR_KILO5")
   AddNaoUsado(aSemSx3,"YR_VALOR5") 
   AddNaoUsado(aSemSx3,"YR_KILO6")
   AddNaoUsado(aSemSx3,"YR_VALOR6")
   AddNaoUsado(aSemSx3,"YR_20")    
   AddNaoUsado(aSemSx3,"YR_40")
   AddNaoUsado(aSemSx3,"YR_40_HC")
   AddNaoUsado(aSemSx3,"YR_OUTROS")
   AAdd(aSemSx3,{"RECNO"     ,"N", 7,0}) 
   //TRP - 25/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   
   
   // ** JBJ - 04/01/2002 - 9:65
   If EasyEntryPoint("EECPEM43")
      ExecBlock("EECPEM43",.F.,.F.)
   Endif

   IF nOpc == INCLUIR
      // CRIAR VARIAVEIS DE MEMORIA ...
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next nInc
      bOk := {|| nOpcA:=1, IF(CV100Valid(nOpc),oDlg:End(),nOpcA:=0) }
   Else
      For nInc := 1 TO (cALIAS)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
      Next nInc
      If nOpc = VISUALIZAR
         bOK:={||oDlg:End()}
      ElseIf nOpc==ALTERAR
         bOk := {|| nOpcA:=1, IF(CV100Valid(nOpc),oDlg:End(),nOpcA:=0) }
         If ! SYQ->(Reclock("SYQ",.F.))  // By JPP - 18/04/2005 - 11:05 - Bloquear o registro durante a alteração.
               Break
         EndIf
      ElseIf nOpc = EXCLUIR
             If !ValExcVia(SYQ->YQ_VIA,"","",.T.,"1")      //NCF - 14/12/2015
                Break
             EndIf
             IF ! INTEGREF("SYQ")
                BREAK
             ENDIF
             If ! SYQ->(Reclock("SYQ",.F.))  // By JPP - 18/04/2005 - 11:05 - Bloquear o registro durante a exclusão.
                Break
             EndIf
             bOk := {|| nOpcA:=2, IF (CV100Valid(nOpc),oDlg:End(),nOpcA:=0) } //"Confirma Exclusão ?"###"Atenção"
      EndIf
   Endif
   
   DbSelectArea("SYQ")
   
   // ** Cria as Works necessárias para a manutenção.
   // ** Work das Origens e Destinos.
   aCampos := Array(SYR->(FCount()))
   cNomArq := E_CriaTrab("SYR",aSemSx3)
   IndRegua("TRB",cNomArq+TEOrdBagExt(),"YR_ORIGEM+YR_DESTINO+YR_TIPTRAN")

   aSemSx3:={}
   AddNaoUsado(aSemSx3,"EX3_VIA")
   Aadd(aSemSx3,{"RECNO","N",7,0})          
   aCampos  := Array(EX3->(FCount()))
   cNomArq2 := E_CriaTrab("EX3",aSemSx3,"WorkAg")
   IndRegua("WorkAg",cNomArq2+TEOrdBagExt(),"EX3_ORIGEM+EX3_DEST+EX3_AGENTE")

   aSemSx3:={}
   AddNaoUsado(aSemSx3,"EX4_VIA")
   AddNaoUsado(aSemSx3,"EX4_ORIGEM")
   AddNaoUsado(aSemSx3,"EX4_DEST")
   AddNaoUsado(aSemSx3,"EX4_AGENTE")
   Aadd(aSemSx3,{"RECNO","N",7,0})          
   aCampos  := Array(EX4->(FCount()))
   cNomArq3 := E_CriaTrab("EX4",aSemSx3,"WorkFre")
   IndRegua("WorkFre",cNomArq3+TEOrdBagExt(),"EX4_ORIGEM+EX4_DEST+EX4_AGENTE") 

   // ** Carrega todas as works.
   CV100LoadWorks()
                  	
   TRB->(dbGoTop())
   nOpcA := 0

    If !lSYQAuto
        DEFINE MSDIALOG oDlg TITLE cCADASTRO FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL   

            EnChoice( cAlias, nReg, nOpc,,,,GetCampos(cAlias, nOpc),PosDlgUp(oDlg), , 3 )
            oSelect := MsSelect():New("TRB",,,aSelectFields,,,PosDlgDown(oDLG))
            oSelect:bAval := {|| IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),CV100Det(VIS_DET,oSelect),CV100Det(ALT_DET,oSelect)) }

        ACTIVATE MSDIALOG oDlg ON INIT AVBar(nOpc,oDlg,bOk,bCancel,ENCH_ADD,{|opc| CV100Det(opc,oSelect)},,aBOTAO)
    else
        EnchAuto(cAlias,aSYQAuto, {|| Obrigatorio(aGets, aTela) } ,nOpc,GetCampos(cAlias, nOpc))
        If lMsErroAuto
            lRet := .F.
            Break
        ElseIf nOpc <> EXCLUIR
            for i:=1 to len(aSYRAuto)
                if AvKeyAuto(aSYRAuto)
                    If EasySeekAuto("TRB", aSYRAuto[i], 1)
                        If aScan(aSYRAuto[i], {|x| x[1] == "AUTDELETA" .And. x[2] == "S" }) > 0
                            CV100Det(EXC_DET, ,.F.,aSYRAuto[i])
                        Else
                            CV100Det(ALT_DET, ,.F.,aSYRAuto[i])
                        EndIf
                    Else 
                        If aScan(aSYRAuto[i], {|x| x[1] == "AUTDELETA" .And. x[2] == "S" }) > 0
                            EasyHelp(STR0038,STR0028) // "Origem e destino da via de transporte não encontrados!" , Atenção
                        else
                            CV100Det(INC_DET, ,.F.,aSYRAuto[i])
                        endif
                    EndIf
                else
                    EasyHelp(STR0039,STR0028) // "Erro na estrutura de array dos itens para integração automática!" , Atenção
                endif
            next
        endif
        If !lMsErroAuto
            If CV100Valid(nOpc)
                nOpcA:=iif( nOpc <> EXCLUIR , 1 , 2 )
            Else
                nOpcA:=0
            EndIf
        EndIf
    endif

   If nOpcA == 1
      Begin Transaction
         Processa({|| CV100Grava(nReg)})
        
         //JVR - 05/10/09
         If(EasyEntryPoint("EECCV100"),Execblock("EECCV100",.F.,.F.,"APOS_GRV_EX4"),)

         //Processa Gatilhos
         EvalTrigger()
         If __lSX8
            ConfirmSX8()
         Endif
      End Transaction
      MsUnLockAll()
   Elseif nOpcA == 2 
      Begin Transaction
         EX3->(DbSetOrder(1))
         EX4->(DbSetOrder(1))
         SYR->(dbSeek(xFilial()+SYQ->YQ_VIA))

         // ** Apaga os agentes marítimos e respectivos fretes.
         While SYR->( !Eof() .And. xFilial()==SYR->YR_FILIAL .AND. SYQ->YQ_VIA == SYR->YR_VIA )
            If EX3->(DbSeek(xFilial("EX3")+SYQ->YQ_VIA+SYR->YR_ORIGEM+SYR->YR_DESTINO))
               Do While EX3->(!Eof()) .And. EX3->EX3_FILIAL == xFilial("EX3") .And.;
                                            EX3->EX3_VIA    == SYQ->YQ_VIA .And.;
                                            EX3->EX3_ORIGEM == SYR->YR_ORIGEM .And.;
                                            EX3->EX3_DEST   == SYR->YR_DESTINO 

                  EX4->(DbSeek(xFilial("EX4")+EX3->EX3_VIA+EX3->EX3_ORIGEM+EX3->EX3_DEST+EX3->EX3_AGENTE))
                  Do While EX4->(!Eof()) .And. EX4->EX4_FILIAL == xFilial("EX4") .And.;
                                               EX4->EX4_VIA    == EX3->EX3_VIA .And.;
                                               EX4->EX4_ORIGEM == EX3->EX3_ORIGEM .And.;
                                               EX4->EX4_DEST   == EX3->EX3_DEST .And.;
                                               EX4->EX4_AGENTE == EX3->EX3_AGENTE
                     EX4->(RecLock("EX4",.f.))
                     EX4->(dbDelete())
                     EX4->(DbSkip())
                  EndDo

                  EX3->(RecLock("EX3",.f.))
                  EX3->(dbDelete())
                  EX3->(DbSkip())
               EndDo
            EndIf

            SYR->(RecLock("SYR",.f.))
            SYR->(dbDelete())
            SYR->(dbSkip())
         Enddo
         SYQ->(RecLock("SYQ",.F.))
         SYQ->(dbDelete())
      End Transaction
      MsUnLockAll()
   Elseif nOpcA == 0
      SYQ->(MSUnlock()) // By JPP - 18/04/2005 - 11:05
      If __lSX8
         RollBackSX8()
      Endif
   Endif

   For j:=1 To Len(aWorks)
      If Select(aWorks[j][1]) > 0
         cEraseTmp := &(aWorks[j][2])
         (aWorks[j][1])->(E_EraseArq(cEraseTmp))
      EndIf
   Next

End Sequence

Return NIL

/*
Funcao     : GetCampos()
Parametros : nOpc
Retorno    : aCampos - Campos que serão exibidos na Enchoice
Objetivos  : Retornar os campos que serão exibidos na Enchoice, considerando o array aNotShow, com os campos possuem restrições para serem exibidos.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 31/10/07 - 09:30
*/
Static Function GetCampos(cAlias, nOpc)
Local lLoop, nInc, nPos
Local aOrd := SaveOrd("SX3")
Local aCampos := {}
Local aNotShow := {{"YQ_ABICS", {|| EECFlags("CAFE") } }}

   SX3->(DbSeek(cAlias))
   While SX3->(!Eof() .And. X3_ARQUIVO == cAlias)
      lLoop := .F.
      If (nPos := aScan(aNotShow, {|x| SX3->X3_CAMPO == If(ValType(x) == "A", IncSpace(x[1], 10, .F.), IncSpace(x, 10, .F.)) })) > 0
         If ValType(aNotShow[nPos]) <> "A" .Or. Len(aNotShow[nPos]) == 1
            lLoop := .T.
         Else
            For nInc := 2 To Len(aNotShow[nPos])
               If !Eval(aNotShow[nPos][nInc])
                  lLoop := .T.
                  Exit
               EndIf
            Next
         EndIf
      EndIf
      If !X3Uso(SX3->X3_USADO)
         lLoop := .T.
      EndIf
      If lLoop
         SX3->(DbSkip())
         Loop
      EndIf
      aAdd(aCampos, SX3->X3_CAMPO)
      SX3->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return aCampos
           
/*
Funcao      : CV100Grava
Parametros  : cAlias := alias arq.
              nReg   := num.registro
              nOpc   := opcao escolhida
Retorno     : .T. 
Objetivos   : Grava Vias de Transporte
Autor       : Cristiano A. Ferreira
Data/Hora   : 14/07/1999 11:45
Revisao     :
Obs.        :
*/
STATIC Function CV100Grava(nReg)

LOCAL i, y:=0, z:=0

Begin Transaction

   ProcRegua(TRB->(LastRec())+WorkAg->(LastRec())+WorkFre->(LastRec())+1)

   IncProc(STR0008) //"Atualizando arquivos ..."
   E_Grava("SYQ",Inclui)

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Grava arquivo SYR (Tarifas de Frete)                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   For i:=1 To Len(aDeletados)
      IncProc()
      SYR->(dbGoTo(aDeletados[i]))
      SYR->(RecLock("SYR",.f.))
      SYR->(dbDelete())
   Next

   TRB->(dbGoTop())
 
   While ! TRB->(Eof())   
      IncProc()

      IF TRB->RECNO == 0
         SYR->(RecLock("SYR",.t.))
         SYR->YR_FILIAL := xFilial("SYR")
         SYR->YR_VIA    := SYQ->YQ_VIA
      Else
         SYR->(dbGoTo(TRB->RECNO))
         SYR->(RecLock("SYR",.f.))
      Endif
      AVREPLACE("TRB","SYR")
      TRB->(dbSkip())
   Enddo

   For y:=1 To Len(aAgDeletados)
      IncProc()
      EX3->(dbGoTo(aAgDeletados[y]))
      EX3->(RecLock("EX3",.f.))
      EX3->(DbDelete())
   Next   
   
   TRB->(DbGoTop())
 
   // ** Grava os agentes marítimos.  
   WorkAg->(DbGoTop())
   Do While !WorkAg->(Eof()) 
      IncProc()

      IF WorkAg->RECNO == 0
         EX3->(RecLock("EX3",.t.))
         EX3->EX3_FILIAL := xFilial("EX3")
         EX3->EX3_VIA    := SYQ->YQ_VIA
      Else
         EX3->(DbGoTo(WorkAg->RECNO))
         EX3->(RecLock("EX3",.f.))
      Endif
      AvReplace("WorkAg","EX3")
      WorkAg->(dbSkip())
   EndDo
   WorkAg->(DbGoTop())   
   
   For z:=1 To Len(aFreDeletados)
      IncProc()
      EX4->(dbGoTo(aFreDeletados[z]))
      EX4->(RecLock("EX4",.F.))
      EX4->(DbDelete())
   Next

   // ** Grava os taxas de frete marítmos.
   WorkFre->(DbGoTop())
   Do While !WorkFre->(Eof())
      IncProc()

      IF WorkFre->RECNO == 0
         EX4->(RecLock("EX4",.t.))
         EX4->EX4_FILIAL := xFilial("EX4")
         EX4->EX4_VIA    := SYQ->YQ_VIA
      Else
         EX4->(DbGoTo(WorkFre->RECNO))
         EX4->(RecLock("EX4",.f.))
      Endif
      AvReplace("WorkFre","EX4")
      WorkFre->(dbSkip())
   EndDo
   WorkFre->(DbGoTop())

End Transaction
MsUnLockAll()

Return (.t.)

/*
Funcao      : CV100LoadWorks()
Parametros  : nenhum.
Retorno     : .t.
Objetivos   : Carregar as works necessárias para a manutenção de Vias de Transporte.
Autor       : Jeferson Barros Jr.
Data/Hora   : 04/09/2003 15:14.
Revisao     : mai/2017
              Filtrar os registros a serem exibidos no cadastro quando acessados pelo SIGAEEC.
              Considerar os países de destino diferente de Brasil.
Obs.        :
*/
*------------------------------*
Static Function CV100LoadWorks()
*------------------------------*
Local aOrd:=SaveOrd({"SYR","EX3","EX4"}), aAux:={}
Local lRet:=.t., j:=0

Begin Sequence

   // ** Carrega Work com as Origens e Destinos.
   lEXEEC := .F.
   SYR->(DbSetOrder(1))
   SYR->(DbSeek(xFilial("SYR")+AvKey(M->YQ_VIA,"YR_VIA"))) 

   Do While SYR->(!Eof()) .And. SYR->YR_FILIAL == xFilial("SYR") .And.;
                                SYR->YR_VIA    == AvKey(M->YQ_VIA,"YR_VIA")
      If !Empty(SYR->YR_PAIS_DE) //wfs 31/05/2017
      //If !Empty(SYR->YR_PAIS_DE) .And. (cPaisLoc <> "BRA" .Or. SYR->YR_PAIS_DE <> "105")
         TRB->(dbAppend())
         TRB->RECNO := SYR->(RecNo())
         AvReplace("SYR","TRB")
         TRB->TRB_ALI_WT:= "SYR"
         TRB->TRB_REC_WT:= SYR->(Recno())
      Else
        lEXEEC := .t.
      EndIf
      SYR->(DbSkip())
   EndDo

   // ** Carrega Work com os Agentes.
   EX3->(DbSetOrder(1))

   TRB->(DbGoTop())
   Do While TRB->(!Eof())     
      EX3->(DbSeek(xFilial("EX3")+AvKey(M->YQ_VIA,"EX3_VIA")+TRB->YR_ORIGEM+TRB->YR_DESTINO))
      Do While EX3->(!Eof()) .And. EX3->EX3_FILIAL == xFilial("EX3") .And.;
                                   EX3->EX3_VIA  == AvKey(M->YQ_VIA,"EX3_VIA") .And.;
                                   EX3->EX3_ORIGEM  == TRB->YR_ORIGEM .And.;
                                   EX3->EX3_DEST    == TRB->YR_DESTINO
         WorkAg->(DbAppend())
         WorkAg->RECNO := EX3->(RecNo())
         AvReplace("EX3","WorkAg")
         EX3->(DbSkip())
      EndDo
      TRB->(DbSkip())
   EndDo

   // ** Carrega Work com as Tarifas de Fretes Marítimos.
   EX4->(DbSetOrder(1))

   WorkAg->(DbGoTop())
   Do While WorkAg->(!Eof())
      EX4->(DbSeek(xFilial("EX3")+WorkAg->EX3_VIA+WorkAg->EX3_ORIGEM+WorkAg->EX3_DEST+WorkAg->EX3_AGENTE))
      Do While EX4->(!Eof()) .And. EX4->EX4_FILIAL  == xFilial("EX4")      .And.;
                                   EX4->EX4_VIA     == WorkAg->EX3_VIA     .And.;
                                   EX4->EX4_ORIGEM  == WorkAg->EX3_ORIGEM  .And.;
                                   EX4->EX4_DEST    == WorkAg->EX3_DEST    .And.;
                                   EX4->EX4_AGENTE  == WorkAg->EX3_AGENTE
         WorkFre->(DbAppend())
         WorkFre->RECNO := EX4->(RecNo())
         AvReplace("EX4","WorkFre")
         EX4->(DbSkip())
      EndDo

      WorkAg->(DbSkip())
   EndDo

   aAux:={"TRB","WorkAg","WorkFre"}
   For j:=1 To Len(aAux)
     (aAux[j])->(DbGoTop())
   Next

End Sequence

RestOrd(aOrd)

Return lRet

/*-------------------------------------------------------------------
Funcao      : CV100Det
Parametros  : nOpc := 2 // Visualizacao
                      3 // Inclusao
                      4 // Alteracao
                      5 // Exclusao
              oSelect - Objeto para refresh.
              lShowBt - ( .t. - Mostra botões de fretes por kg./Agentes Marítimos)
Retorno     : NIL
Objetivos   : Manutencao dos detalhes das Vias de Transporte
Autor       : Cristiano A. Ferreira
Data/Hora   : 14/07/1999 15:55
Revisao     :
Obs.        :
*/
STATIC Function CV100Det(nOpc, oSelect,lShowBt,aAuto)
Local nAreaOld := Select() 
LOCAL oDlg, nOpcA:=0
LOCAL nInc
LOCAL nReg

LOCAL bOk      := {||nOpcA:=1,IF(CV100ValDet(nOpc,nReg),If(!lSYQAuto, oDlg:End(), Nil),nOpcA:=0)}
LOCAL bCancel  := {|| oDlg:End()}
Local aButtons := {}
Local aCpoAltera := {}

Private aTela[0][0],aGets[0],nUsado:=0

Default lShowBt := .f.

dbSelectArea("SYQ")

Begin Sequence
  
    aCpoAltera:={"YR_ORIGEM","YR_DESTINO","YR_TRANS_T","YR_TIPTRAN", "YR_CID_DES"}
   
    If nOpc == INC_DET
        If Empty(M->YQ_VIA)
            EasyHelp(STR0030+AvSx3("YQ_VIA",AV_TITULO)+STR0031,STR0007) //"Código da via não informado. O campo '"###"' deve ser preenchido."###"Atenção"
            Break
        EndIf
    EndIf

    aAdd(aButtons,{"POSCLI",({|| Cv200AgMan(If(nOpc==VIS_DET,.t.,.f.)) } ),STR0034}) //"Agentes"
   
    If nOpc == 5         // CCM - 22/05/09 - Novo tratamento para alteração de Agentes.
        aCpoAltera:={"YR_TRANS_T" /*,"YR_PAIS_DE"*/,"YR_CID_DES","YR_TIPTRAN"}     // GFP - 07/11/2012
    Endif

    IF nOpc != INC_DET .And. TRB->(EOF()) .AND. TRB->(BOF())
        HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
        Break
    EndIf

    If !lShowBt
        If nOpc == INC_DET // INCLUIR
            M->YR_VIA := M->YQ_VIA
        EndIf
    
        nReg := TRB->(RecNo())

        For nInc := 1 TO TRB->(FCount())
            IF AllTrim(TRB->(FieldName(nInc))) $ "DBDELETE,RECNO,TRB_ALI_WT,TRB_REC_WT"
                Loop
            Endif
        
            IF nOpc == INC_DET // Inclusao
                M->&(TRB->(FIELDNAME(nInc))) := CriaVar(TRB->(FieldName(nInc)))
            Else
                M->&(TRB->(FIELDNAME(nInc))) := TRB->(FIELDGET(nInc))
            Endif
        Next nInc
    EndIf     
    
    //OAP -05/11/2010- Inclusão dos campos adicionados pelo usuário
    aEnchoice := AddCpoUser(aEnchoice,"SYR","1")
    aCpoAltera := AddCpoUser(aCpoAltera,"SYR","1")
    

   While .T.
         nOpcA := 0
         aTela := {}
         aGets := {}

        If !lSYQAuto

            DEFINE MSDIALOG oDlg TITLE STR0032+M->YQ_VIA FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Origens e Destinos da Via "
                EnChoice("SYR", , 3, , , ,aEnchoice , PosDlg(oDLG), IF(STR(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aCpoAltera),3)
            ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) // ** By JBJ - 04/09/03 - 11:25

        else
            IF nOpc == INC_DET
                nAux := 3
            Elseif nOpc == ALT_DET
                nAux := 4
            else
                nAux := 5
                if CV100ValDet(nOpc,nReg)
                    nOpcA := 1
                else
                    nOpcA := 0 
                endif
            endif
            EnchAuto("SYR",aAuto,{|| iif( CV100ValDet(nOpc,nReg), nOpcA := 1 , nOpcA := 0 ) },nAux, aEnchoice )
        endif

         IF nOpcA == 1 // Ok
            IF nOpc == INC_DET
               TRB->(DBAPPEND())
               nReg := TRB->(RecNo())
            Endif

            IF ! Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
               TRB->(DBGOTO(nReg))

               For nInc:= 1 TO TRB->(FCount())
                  IF AllTrim(TRB->(FieldName(nInc))) $ "RECNO,DBDELETE,TRB_ALI_WT,TRB_REC_WT"
                     Loop
                  Endif
                  TRB->(FieldPut(nInc,M->&(FIELDNAME(nInc))))
               Next
               TRB->TRB_ALI_WT:= "SYR"
               TRB->TRB_REC_WT:= SYR->(Recno())
            EndIF
            If !lSYQAuto
               oSelect:oBrowse:Refresh()        
            EndIf
            Exit                  
         Elseif nOpcA == 0 // Cancel
            IF nOpc == INC_DET
               If WorkAg->(DbSeek(M->YR_ORIGEM+M->YR_DESTINO))
                  Do While WorkAg->(!Eof()) .And. WorkAg->EX3_ORIGEM == M->YR_ORIGEM .And.;
                                                  WorkAg->EX3_DEST   == M->YR_DESTINO

                     // ** Deleta as tarifas maritimas cadastradas para o agente a ser excluido.
                     WorkFre->(DbSeek(WorkAg->EX3_ORIGEM+WorkAg->EX3_DEST+WorkAg->EX3_AGENTE))
                     Do While WorkFre->(!Eof()) .And. WorkFre->EX4_ORIGEM == WorkAg->EX3_ORIGEM .And.;
                                                      WorkFre->EX4_DEST   == WorkAg->EX3_DEST .And.;
                                                      WorkFre->EX4_AGENTE == WorkAg->EX3_AGENTE
                        If WorkFre->RECNO <> 0
                           aAdd(aFreDeletados,WorkFre->RECNO)
                        EndIf
                        WorkFre->(DbDelete())
                        WorkFre->(DbSkip())
                     EndDo 

                     If WorkAg->RECNO <> 0
                        aAdd(aAgDeletados,WorkAg->RECNO)
                     EndIf
                     WorkAg->(DbDelete())
                     WorkAg->(DbSkip())
                  EndDo
               EndIf
            EndIf
            Exit
         Endif
   Enddo
End Sequence

Select(nAreaOld) // CAF - 27/04/2000 - Enchoice muda a area corrente

Return NIL

/*
Funcao      : CV100ValDet
Parametros  : nOpc := 2 // Visualizacao
                      3 // Inclusao
                      4 // Alteracao
                      5 // Exclusao
              nReg := Numero do Registro
Retorno     : .T./.F.
Objetivos   : Consistencias dos detalhes da Via de Transp.
Autor       : Cristiano A. Ferreira
Data/Hora   : 15/07/1999 09:21
Revisao     :
Obs.        :
*/
STATIC Function CV100ValDet(nOpc,nReg)
LOCAL lRet := .T.
Begin Sequence
    IF Str(nOpc,1) $ Str(INC_DET,1)+"/"+Str(ALT_DET,1)
        IF ! Obrigatorio(aGets,aTela)
            lRet := .F.
            Break
        Endif
        
    Elseif nOpc == EXC_DET
        If !ValExcVia(M->YQ_VIA,TRB->YR_ORIGEM,TRB->YR_DESTINO,.T.,"2")      //NCF - 14/12/2015
            lRet := .F.
            Break
        EndIf

        IF (Type("lSYQAuto") == "L" .and. lSYQAuto) .or. MsgYesNo(STR0010,STR0007) //"Confirma Exclusão do registro atual ?"###"Atenção"
            WorkAg->(DbSetOrder(1))
            WorkFre->(DbSetOrder(1))

            // ** Deleta os agentes para a origem e destino.   
            WorkAg->(DbSeek(TRB->YR_ORIGEM+TRB->YR_DESTINO))
            Do While WorkAg->(!Eof()) .And. WorkAg->EX3_ORIGEM == TRB->YR_ORIGEM .And.;
                                            WorkAg->EX3_DEST   == TRB->YR_DESTINO

                // ** Deleta as tarifas maritimas cadastradas para o agente a ser excluido.
                WorkFre->(DbSeek(WorkAg->EX3_ORIGEM+WorkAg->EX3_DEST+WorkAg->EX3_AGENTE))
                Do While WorkFre->(!Eof()) .And. WorkFre->EX4_ORIGEM == WorkAg->EX3_ORIGEM .And.;
                                                WorkFre->EX4_DEST   == WorkAg->EX3_DEST .And.;
                                                WorkFre->EX4_AGENTE == WorkAg->EX3_AGENTE
                If WorkFre->RECNO <> 0
                    aAdd(aFreDeletados,WorkFre->RECNO)
                EndIf
                WorkFre->(DbDelete())
                WorkFre->(DbSkip())
                EndDo 

                If WorkAg->RECNO <> 0
                aAdd(aAgDeletados,WorkAg->RECNO)
                EndIf
                WorkAg->(DbDelete())
                WorkAg->(DbSkip())
            EndDo

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

/*
Funcao      : CV100Valid(nOpc)
Parametros  : nOpc := 2 - Visualizacao
                      3 - Inclusao
                      4 - Alteracao
                      5 - Exclusao
Retorno     : .T./.F.
Objetivos   : Consistencias do SYQ
Autor       : Cristiano A. Ferreira
Data/Hora   : 15/07/99 09:52
Revisao     :
Obs.        :
*/
Static Function CV100Valid(nOpc)

LOCAL lRet := .T.   
Private lValidTransp:= lRet  
    
Begin Sequence
    IF Str(nOpc,1) $ Str(INCLUIR,1)+"/"+Str(ALTERAR,1)
        IF ! Obrigatorio(aGets,aTela)
            lRet := .F.
            Break
        Endif
    Elseif nOpc == EXCLUIR
        if (Type("lSYQAuto") == "L" .and. !lSYQAuto) .or. (Type("lSYQAuto") <> "L")
            IF ! MsgYesNo(STR0006,STR0007) //"Confirma Exclusão ?"###"Atenção"
                lRet := .F.
                Break 
            Endif
        endif
    Endif
End Sequence

//DFS - 17/11/10 - Criação de ponto de entrada para validação de via de transporte.
If EasyEntryPoint("EECCV100")
   Execblock("EECCV100",.F.,.F.,{"CV100VALID_VIATRANSP", nOpc})
EndIf

If ValType(lValidTransp) == "L"
   lRet:= lValidTransp
EndIf

Return lRet

/*
Funcao      : CV100Vld(cCpo)
Parametros  : cCpo := Nome do Campo a ser consistido
Retorno     : .T./.F.
Objetivos   : Consistencias do SYR
Autor       : Cristiano A. Ferreira
Data/Hora   : 15/07/99 09:52
Revisao     : AMS - 02/02/2004 às 16:27. Atribuição da Static Function CV100Vld como Function, 
              devido a chamada que esta sendo feita no valid do YR_ORIGEM.
              wfs - mai/2017: consistir que para os cadastros de vias de transporte incluídos pelo módulo
              SIGAEEC o país de destino não seja o Brasil.
Obs.        :
*/
Function CV100Vld(cCpo)
LOCAL lRet := .T.
LOCAL nRecNo
Local cMsg:= ""

DO CASE
   CASE cCpo == "YR_DESTINO"
      IF M->YR_DESTINO == M->YR_ORIGEM
         HELP(" ",1,"EA200ORIDE")
         RETURN .F.
      ENDIF

      IF TRB->(LASTREC()) > 0
         IF !Empty(M->YR_ORIGEM) .And. !Empty(M->YR_DESTINO) .And.;
            !Empty(M->YR_TIPTRAN)
            nRecNo := TRB->(RecNo())
            IF TRB->(dbSeek(M->YR_ORIGEM+M->YR_DESTINO+M->YR_TIPTRAN))
               HELP(" ",1,"AVG0005020") //MsgStop("Origem/Destino já cadastrado !","Atenção")
               lRet := .F.
            Endif
            TRB->(dbGoTo(nRecNo))
         Endif
      ENDIF

      SY9->(DBSETORDER(2))
      If !Empty(cMsg)
         EasyHelp(cMsg, STR0025) //"Aviso"
         lRet:= .F.
      EndIf

      IF ( lRET )
         //SY9->(DBSETORDER(2)) //comentado por wfs
         IF ( SY9->(DBSEEK(XFILIAL("SY9")+M->YR_DESTINO)))
            M->YR_PAIS_DE:=SY9->Y9_PAIS
            M->YR_CID_DES:=SY9->Y9_CIDADE
         ENDIF
      ENDIF
      lREFRESH:=.T.
   CASE cCpo == "YR_ORIGEM"
      IF M->YR_ORIGEM == M->YR_DESTINO
         HELP(" ",1,"EA200ORIDE")
         RETURN .F.
      ENDIF
      
      IF TRB->(LASTREC()) > 0
         IF !Empty(M->YR_ORIGEM) .And. !Empty(M->YR_DESTINO) .And.;
            !Empty(M->YR_TIPTRAN)
            nRecNo := TRB->(RecNo())
            IF TRB->(dbSeek(M->YR_ORIGEM+M->YR_DESTINO+M->YR_TIPTRAN))
               HELP(" ",1,"AVG0005020") //MsgStop("Origem/Destino já cadastrado !","Atenção")
               lRet := .F.
            Endif
            TRB->(dbGoTo(nRecNo))
         Endif
      ENDIF

      If !Empty(cMsg)
         EasyHelp(cMsg, "Aviso")
         lRet:= .F.
      EndIf

   CASE cCpo == "YR_TIPTRAN"
      IF TRB->(LASTREC()) > 0
         IF !Empty(M->YR_ORIGEM) .And. !Empty(M->YR_DESTINO) .And.;
            !Empty(M->YR_TIPTRAN)
            nRecNo := TRB->(RecNo())
            IF TRB->(dbSeek(M->YR_ORIGEM+M->YR_DESTINO+M->YR_TIPTRAN))
               HELP(" ",1,"AVG0005020") //MsgStop("Origem/Destino já cadastrado !","Atenção")
               lRet := .F.
            Endif
            TRB->(dbGoTo(nRecNo))
         Endif
      ENDIF
         
ENDCASE

Return lRet

*--------------------------------------------------------------------
STATIC FUNCTION CV100PESQ()
LOCAL oDLG,bOK,bCANCEL,lBOF,nOPC,lFOUND,nRECNO
*
nRECNO   := TRB->(RECNO())
lFOUND   := .F.
nOPC     := 0
bOK      := {|| nOPC := 1,oDLG:END()}
bCANCEL  := {|| nOPC := 0,oDLG:END()}
lBOF     := .F.                    
                                                
//DFS - 12/03/13 - Redefinido o tamanho da tela de Pesquisa por Origem e Destino 
DEFINE MSDIALOG oDLG TITLE STR0019 FROM 00,00 TO 170,350 OF oMainWnd PIXEL //"Pesquisa Origem/Destino" //C2=268

   oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //LRS - 21/08/2018
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT 

   @ 010,05 CHECKBOX lBOF PROMPT STR0020 SIZE 95,08 OF oPanel PIXEL //"Inicia pesquisa no primeiro registro"
   *
   @ 020,05 SAY STR0021 SIZE 50,08 OF oPanel PIXEL //"Codigo Origem"
   @ 020,50 MSGET cORIGEM       SIZE 15,08 OF oPanel PIXEL F3("EY9") VALID(CV100VAL(1))
   *
   @ 030,05 SAY STR0022 SIZE 50,08 OF oPanel PIXEL //"Codigo Destino"
   @ 030,50 MSGET cDESTINO       SIZE 15,08 OF oPanel PIXEL F3("EY9") VALID(cV100VAL(2))
   *
   @ 040,005 SAY STR0023 SIZE 50,08 OF oPanel PIXEL //"Cidade de Destino"
   @ 040,50 MSGET cCIDADED           SIZE 80,08 OF oPanel PIXEL

ACTIVATE MSDIALOG oDLG ON INIT ENCHOICEBAR(oDLG,bOK,bCANCEL) CENTERED
IF nOPC = 1 .AND. ! EMPTY(cORIGEM+cDESTINO+cCIDADED)
   IF lBOF
      TRB->(DBGOTOP())
   ELSE
      TRB->(DBSKIP())
   ENDIF
   DO WHILE .T.
      DO WHILE ! TRB->(EOF())
         IF (EMPTY(cORIGEM)  .OR. cORIGEM  = TRB->YR_ORIGEM)  .AND.;
            (EMPTY(cDESTINO) .OR. cDESTINO = TRB->YR_DESTINO) .AND.;
            (EMPTY(cCIDADED) .OR. ALLTRIM(cCIDADED) = LEFT(TRB->YR_CID_DES,LEN(ALLTRIM(cCIDADED))))
            *
            lFOUND := .T.
            EXIT
         ENDIF
         TRB->(DBSKIP())
      ENDDO      
      IF ! lFOUND
         IF lBOF
            MSGINFO(STR0024,STR0025) //"Nao Existe nenhum registro com estas condicoes !"###"Aviso"
            TRB->(DBGOTO(nRECNO))
            EXIT
         ELSEIF MSGYESNO(STR0024+ENTER+; //"Nao existe nenhum registro com estas condicoes !"
                         STR0026,STR0025) //"Deseja continuar a pesquisa a partir do primeiro registro ?"###"Aviso"
                *
                TRB->(DBGOTOP())
         ELSE
            TRB->(DBGOTO(nRECNO))
            EXIT
         ENDIF
      ELSE
         EXIT
      ENDIF
   ENDDO
ENDIF
RETURN(NIL)
*--------------------------------------------------------------------
FUNCTION CV100VAL(nP_ACAO)
LOCAL lRET,aORD
*
lRET := .T.
aORD := SAVEORD({"SYR"})
IF ( nP_ACAO = 1 .AND. ! EMPTY((cVar := cORIGEM)) ) .Or. ( nP_ACAO = 2 .AND. ! EMPTY((cVar := cDESTINO)) )

   SY9->(DBSETORDER(2))
   IF ! (SY9->(DBSEEK(XFILIAL()+cVar)))
      Help(' ', 1, 'REGNOIS')
      lRET := .F.
   ENDIF
ELSEIF nP_ACAO = 3// JPM 12/09/05
   IF EMPTY(cORIGEM+cDESTINO+cCIDADED)
      MSGINFO(STR0024,STR0025) //"Nao Existe nenhum registro com estas condicoes !"###"Aviso"
      lRet := .f.
   EndIf
ELSEIF nP_ACAO = 4 // GFP - 22/10/2012
   SYR->(DBSETORDER(3))
   IF SYR->(DBSEEK(xFilial('SYR')+M->Y9_SIGLA))
      lRET := .F.
   ENDIF
   SYR->(DBSETORDER(4))
   IF SYR->(DBSEEK(xFilial('SYR')+M->Y9_SIGLA))
      lRET := .F.
   ENDIF
ENDIF
RESTORD(aORD)
RETURN(lRET)