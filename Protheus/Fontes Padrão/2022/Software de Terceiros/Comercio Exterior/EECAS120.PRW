#INCLUDE "EECAS120.ch"

/*
   Programa : EECAS120.PRW 
   Autor    : Heder M Oliveira    
   Data     : 08/06/99 11:42
   Revisao  : 08/06/99 11:42
   Uso      : Manutencao de paises
*/

#include "EEC.CH"

/*
Funcao		: EECAS120()
Parametros	: Nenhum
Retorno		: .T.
Objetivos	: Manutencao de Paises
Autor		: Heder M Oliveira
Data/Hora	: 03/12/98 17:51
Revisao		:
Obs.		:
*/
Function EECAS120( )
Local lRet:=.T.,aORD:=SAVEORD({"EEA","SYA"})

Private aRotina := MenuDef()

Private cCADASTRO:=AVTITCAD("SYA") //"Países"
	EEA->(dbSetOrder(1))
	SYA->(dbSetOrder(1))
	
	Begin sequence
	mBrowse( 6, 1,22,75,"SYA")
	RESTORD(aORD,.T.)
	End sequence

Return lRet


/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 22/01/07 - 17:30
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina := {}
  
  aRotina := { { STR0001, "AXPESQUI"  , 0 , 1},; //"Pesquisar"
					{ STR0002, "AS120MAN"  , 0 , 2},; //"Visualizar"
					{ STR0003, "AS120MAN"  , 0 , 3},; //"Incluir"
					{ STR0004, "AS120MAN"  , 0 , 4},; //"Alterar"
					{ STR0005, "AS120MAN"  , 0 , 5},; //"Excluir"
               { STR0031, 'TE110Inclui("B",SYA->YA_CODGI)'  , 0 , 4}} //Tabela de/Para

   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("EAS120MNU")
	  aRotAdic := ExecBlock("EAS120MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
         AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf

Return aRotina
                             
/*
Funcao		: AS120MAN()
Parametros	:
Retorno		:
Objetivos	:
Autor		: Heder M Oliveira
Data/Hora	:
Revisao		:
Obs.		:
*/
Function AS120MAN(cAlias,nReg,nOpc)

Local lRet:=.T.,oDlg,nInc,bOK,bCANCEL:={||nOpcA:=0,oDlg:End()}
Local lGravaOK:=.T.
Local lEditDoc := (nOpc == INCLUIR .Or. nOpc == ALTERAR)
Local cArq1, cIndArq1, cArq2, cArq3,aBUTTONS:={}
Local aOrd := SaveOrd("EE1",3)
Local cCodId   := UPPER(AvKey(EasyGParam("MV_AVG0035",,"PORT."),"X5_CHAVE"))
Local oMsSelect

Private cOldIdioma
Private bEndDialog := {|| nOpcA:=5,If(type("oDlg")=="O",oDlg:End(),) }
Private lGrvWork := .f.
Private aTela[0][0],aGets[0],nUSADO:=0
Private aCampos,aHeader[0],nOpcA:=3
Private aCampoDET:={ColBrw("EE1_ORDEM","Work1"),;
                    {{|| Work1->EE1_FASE+"-"+If(Work1->EE1_FASE="1","Todas",If(Work1->EE1_FASE="2",STR0016,; //"Processo"
                         If(Work1->EE1_FASE="3",STR0017,STR0018)))},"",STR0019},;  //"Embarque"###"Financas"###"Fase"
                    {{|| Work1->EE1_TIPDOC},"",STR0020},; //"Tipo"
                    {{|| Work1->EE1_DOCUM },"",STR0006},; //"Código"
                    {{|| BuscaDoc(Work1->EE1_DOCUM) },"",STR0007}} //"Documento"

Private cMarca := GetMark()
Private lInverte := .F.
Private nOrdem := 1
Private lHabilita:= .T.

Private cSXBID := IncSpace(cCodId+"-"+Tabela("ID",cCodId),AVSX3("EE4_IDIOMA",AV_TAMANHO),.f.)
Private lRetPE := .T.

IF(EasyEntryPoint("EECAS120"),Execblock("EECAS120",.F.,.F.,"HABILITA_BOTAO"),) 
BEGIN SEQUENCE
   
   If lHabilita   
      aAdd(aButtons,{"NOTE",{||nOpcA:=4,oDlg:End()},STR0008 /*, STR0028*/})   //"Sel. Msgs." WFS - 25/09/2012 - Texto Ações Relacionadas.
   Endif
   
   IF nOpc == INCLUIR
      // CRIAR VARIAVEIS DE MEMORIA ...
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next nInc
      bOK:={||If(Obrigatorio(aGets,aTela) .AND. AS120PEVALID(nOpc),(nOpcA:=1,oDlg:End()),nOpca:=0)}
   Else
      If nOpc = VISUALIZAR
         bOK:={||oDlg:End()}
      ElseIf nOpc==ALTERAR
         bOK:={||If(Obrigatorio(aGets,aTela) .AND. AS120PEVALID(nOpc),(nOpcA:=2,oDlg:End()),nOpca:=0)}
         If ! Reclock(cAlias,.F.,,.T.) //ER - Bloqueia Alteração para dois usuarios ao mesmo tempo. 
             Break
         EndIf
      ElseIf nOpc = EXCLUIR
             IF ! INTEGREF("SYA")
                BREAK
             ENDIF
             (cAlias)->(RECLOCK(cALIAS,.F.))
             bOK:={||nOpca:=0,IF(AS120PEVALID(nOpc),(AS120MANE(),oDlg:End()),)}
      EndIf                                                                            
      For nInc := 1 TO (cALIAS)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
      Next nInc  
   Endif
   cOldIdioma := M->YA_IDIOMA
   // *** Cria Work para gravar os registros ja marcados ...     
   aCampos:= ARRAY(EE1->(FCOUNT()))
   aSemSX3:= {}
   //TRP - 25/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0}) 
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   cArq1  := E_CriaTrab("EE1",aSemSX3,"Work1")
   IndRegua("Work1",cArq1+TEOrdBagExt(),"EE1_ORDEM",,,STR0009) //"Processando Arquivo Temporário..."   
   cIndArq1 := CriaTrab(,.f.)
   IndRegua("Work1",cIndArq1+TEOrdBagExt(),"EE1_DOCUM",,,STR0009) //"Processando Arquivo Temporário..."
   Set Index To (cArq1+TEOrdBagExt()), (cIndArq1+TEOrdBagExt())
   
   // *** Carrega os registros do work a partir do EE1 ...
   AS120GrvWork(1)
   IF lEditDoc
      aAdd(aButtons,{"CLIPS" /*"EDITABLE"*/,{||nOpcA:=3,oDlg:End()},STR0010/*,STR0029*/})       //"Sel. Docs" // WFS - 25/09/2012 - Texto Ações Relacionadas.
      aAdd(aButtons,{/*"VCUP"*/"PMSSETAUP",{||MoveUp(oMsSelect,"Work1")},STR0024/*,STR0026*/})  //Para Cima 
      aAdd(aButtons,{/*"VCDOWN"*/"PMSSETADOWN",{||MoveDown(oMsSelect,"Work1")},STR0025/*,STR0027*/}) //Para Baixo

      aSemSX3:= {{"WKMARCA","C",2,0},{"WK_DESDOC","C",AVSX3("EEA_TITULO",AV_TAMANHO),0}}
      //TRP - 25/01/07 - Campos do WalkThru
      AADD(aSemSX3,{"TRB_ALI_WT","C",03,0}) 
      AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
      
      // *** Cria Work para selecao dos documentos ...
      cArq2  := E_CriaTrab("EE1",aSemSX3,"Work2")
      IndRegua("Work2",cArq2+TEOrdBagExt(),"WK_DESDOC",;
               ,,STR0009) //"Processando Arquivo Temporário..."
   Endif
   // *** Cria Work para selecao das mensagens ...
   aCampos:= ARRAY(EE4->(FCOUNT()))
   aSemSX3:= {{"WKMARCA","C",2,0}}
   //TRP - 25/01/07 - Campos do WalkThru
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0}) 
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   cArq3 := E_CriaTrab("EE4",aSemSX3,"Work3")
   // *** Grava Work3 com os registros do EE4 ...
   AS120GrvW3()
   While ( nOpca >= 3 )
      nOpcA:=0           
      aTela := {}
      aGets := {}
         Work1->(dbGoTop())
         DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL     	  
            EnChoice( cAlias, nReg, nOpc,,,,,PosDlgUp(oDlg))         
            oMsSelect := MsSelect():New("Work1",,,aCampoDET,@lInverte,cMarca,PosDlgDown(oDLG))
         ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aBUTTONS)          
         IF nOpcA == 0
            EXIT
         Endif
         Do Case
            Case nOpca == 1 
                Begin Transaction
                    E_Grava(cALIAS,.T.)
                    AS120GrvEE1()
                    AS120GrvMsg()
                End Transaction
            Case nOpcA == 2 
                Begin Transaction
                    E_Grava(cALIAS,.F.)
                    AS120GrvEE1()
                    AS120GrvMsg()
                End Transaction
            Case nOpcA == 3
                AS120Sel(cAlias,nReg,nOpc)
            Case nOpcA == 4
                AS120Msg(cAlias,nReg,nOpc)
            EndCASE
   EndDO                            
   Work1->(E_EraseArq(cArq1,cIndArq1))
   Work3->(E_EraseArq(cArq3))
   IF lEditDoc
      Work2->(E_EraseArq(cArq2))
   ENDIF
   End SEQUENCE

RestOrd(aOrd)

Return lRet

/*
Funcao      : AS120MANE()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Excluir Registros
Autor       : Heder M Oliveira
Data/Hora   : 
Revisao     :
Obs.        :
*/
STATIC Function AS120MANE()
    Local lRet:=.T.,cFILIALEE1:=XFILIAL("EE1"),cSYAPAIS:=AVKEY(SYA->YA_CODGI,"EE1_PAIS")
    Begin sequence
        if Msgnoyes(STR0011,STR0012) //"Confirma Exclusão?"###"Atenção"

            If EasyEntryPoint("EECAS120")
                ExecBlock("EECAS120",.F.,.F.,"PE_EXC_INI")
            EndIf

           BEGIN TRANSACTION 
           EE1->(dbSeek(xFilial()+TR_ARQ+cSYAPAIS+Space(AVSX3("EE1_CODCLI",AV_TAMANHO))))
           While !EE1->(Eof()) .And. EE1->EE1_FILIAL == cFILIALEE1 .And.;
                 EE1->EE1_TIPREL == TR_ARQ .And.EE1->EE1_PAIS == cSYAPAIS .And. EE1->EE1_CODCLI == Space(AVSX3("EE1_CODCLI",AV_TAMANHO))
              Reclock("EE1",.F.)
              EE1->(DBDELETE())
              EE1->(MsUnlock())
              EE1->(dbSkip())
           End
           EE1->(dbSeek(xFilial()+TR_MEN+cSYAPAIS))
           While !EE1->(Eof()) .And. EE1->EE1_FILIAL == cFILIALEE1.And.;
                 EE1->EE1_TIPREL == TR_MEN.And.EE1->EE1_PAIS == cSYAPAIS
              Reclock("EE1",.F.)
              EE1->(DBDELETE())
              EE1->(MsUnlock())
              EE1->(dbSkip())
           End
           SYA->(Reclock("SYA",.F.))
           SYA->(DBDELETE())
           SYA->(MsUnlock())

            If EasyEntryPoint("EECAS120")
                ExecBlock("EECAS120",.F.,.F.,"PE_EXC_FIM")
            EndIf

           END TRANSACTION
        endif
    End Sequence
Return lRet

/*
Funcao      : AS120GrvWork(nExec)
Parametros  : nExec := 1 // Carrega Work1 a partir do EE1
              nExec := 2 // Carrega Work1 a partir do Work2
Retorno     : nil
Objetivos   : Grava arquivo de work
Autor       : Cristiano A. Ferreira
Data/Hora   : 09/06/1999 09:53
Revisao     :
Obs.        :
*/
STATIC Function AS120GrvWork(nExec)     
Local cAlias := iif(nExec==1,"EE1","Work2"),cFILIALEE1:=XFILIAL("EE1")
LOCAL cSYAPAIS:=AVKEY(M->YA_CODGI,"EE1_PAIS")
Local bSeek  := iif(nExec==1,{|| EE1->(dbSeek(xFilial()+TR_ARQ+cSYAPAIS+Space(AVSX3("EE1_CODCLI",AV_TAMANHO))))},;
                             {|| Work2->(dbGoTop())})
Local bWhile := iif(nExec==1,{|| EE1->(!Eof()) .And.;
                                 EE1->EE1_FILIAL == cFILIALEE1 .And.;
                                 EE1->EE1_TIPREL == TR_ARQ .And.; 
                                 EE1->EE1_PAIS == cSYAPAIS .And. EE1->EE1_CODCLI == Space(AVSX3("EE1_CODCLI",AV_TAMANHO))},;
                             {|| Work2->(!Eof())})
Local bSkip  := iif(nExec==1,{|| EE1->(dbSkip())},{|| Work2->(dbSkip())})
Local bFor   := iif(nExec==1,{|| .T.},{|| Work2->WKMARCA == cMarca})
     
Local xValue, bBlock

Eval(bSeek)

While Eval(bWhile)

   IF ! Eval(bFor)
      Eval(bSkip)
      Loop
   Endif

   Work1->(dbAppend())
   AVREPLACE(cALIAS,"WORK1")
   Work1->TRB_ALI_WT:= "EE1"
   Work1->TRB_REC_WT:=  EE1->(Recno())
   IF nExec = 1
      IF Val(Work1->EE1_ORDEM) >= nOrdem
         nOrdem := Val(Work1->EE1_ORDEM)+1
      Endif
   Endif

   Eval(bSkip)
End
        
Return NIL
  
/*
Funcao      : AS120Sel
Parametros  : cAlias := Alias do arquivo
              nReg := Numero do registro
              nOpc := 2 - Visualizar
                      3 - Incluir
                      4 - Alterar
                      5 - Excluir
Retorno     : nil
Objetivos   : Selecao de Documentos
Autor       : Cristiano A. Ferreira
Data/Hora   : 09/06/1999 10:53
Revisao     :
Obs.        :
*/
STATIC Function AS120Sel(cAlias,nReg,nOpc)

Local oDlg
Local aCpos := {{"WKMARCA",""," "},;
               {{|| Work2->EE1_DOCUM},"",STR0006},;  //"Código"
               {{|| Work2->EE1_FASE+"-"+If(Work2->EE1_FASE="1","Todas",If(Work2->EE1_FASE="2",STR0016,; //"Processo"
                    If(Work2->EE1_FASE="3",STR0017,STR0018)))},"",STR0019},;  //"Embarque"###"Financas"###"Fase"
               {{|| Work2->EE1_TIPDOC},"",STR0020},; //"Tipo"
               {{|| BuscaDoc(Work2->EE1_DOCUM)},"",STR0013}} //"Documentos"

Local i, bOk, bCancel, nOpcao := 0
Local xValue

Local bOldBlock := bEndDialog

Local aButtons:={} 

Local oMsSelect

bEndDialog := {|| nOpcao := 3, If(type("oDlg")=="O",oDlg:End(),) }
lGrvWork := .t.

Begin Sequence

   IF Empty(M->YA_IDIOMA)
      HELP(" ",1,"AVG0005005") //MsgStop("Para selecionar os documentos, é necessário informar o idioma.","Atenção")
      Break
   Endif
                                                                                            
   aAdd(aButtons,{"LBTIK",{|| MarkAll("Work2",oMsSelect)},STR0021, STR0030}) //"Marca/Desmarca Todos"

   M->YA_IDIOMA := Left(M->YA_IDIOMA,AVSX3("YA_IDIOMA")[AV_TAMANHO])

   IF ! AS120GrvW2() // Grava Work2
      Break
   Endif
   
   While .t.
      nOpcao := 0
      aTela := {}
      aGets := {}
                     
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
     
      EnChoice( cAlias, nReg, nOpc,,,,,PosDlgUp(oDlg))

      oMsSelect := MsSelect():New("Work2","WKMARCA",,aCpos,@lInverte,@cMarca,PosDlgDown(oDLG))
      
      oMsSelect:bAval := {|| IF(Empty(Work2->WKMARCA),(Work2->WKMARCA := cMarca,Work2->EE1_ORDEM := Str(nOrdem++,AVSX3("EE1_ORDEM",AV_TAMANHO))),;
                                                (Work2->WKMARCA := "  ")) }      

      bOk     := {|| nOpcao := 1, oDlg:End() }
      bCancel := {|| nOpcao := 0, oDlg:End() }
      
      oDlg:lMaximized:=.T. //Maximiliza Janela
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
      
      IF nOpcao == 3 //Refresh
         // Fechar a janela para reconstruir os objetos
         IF ! AS120GrvW2() // Grava Work2
            Break
         Endif
         Loop
      Endif

      IF nOpcao == 0
         Break
      Endif
   
      Work1->(avzap())
   
      AS120GrvWork(2)
      
      Exit
   Enddo
   
End Sequence

bEndDialog := bOldBlock
lGrvWork := .f.

Return NIL

         
/*
Funcao      : AS120GrvW2
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Grava Work2 com informacoes do EEA
Autor       : Cristiano A. Ferreira
Data/Hora   : 09/09/1999 13:40
Revisao     :
Obs.        :
*/
STATIC Function AS120GrvW2
                                            
Local aOrd := SaveOrd("Work1")
Local lRet := .t.,W1,CIDIOMA := M->YA_IDIOMA

Local lFiltroIdioma := EasyGParam("MV_AVG0047",,.T.)
    
Begin Sequence
   Work1->(dbSetOrder(2))

   IF Work2->(EasyReccount("Work2")) == 0
      // *** Grava Work2 com os registros do EEA ...
      EEA->(dbSetOrder(2))
      FOR W1 := 1 TO 3          
          EEA->(dbSeek(xFilial()+IF(lFiltroIdioma,CIDIOMA,"")))
          DO While EEA->(!Eof() .And. EEA_FILIAL == xFilial("EEA")) .And. (EEA->EEA_IDIOMA == CIDIOMA .Or. !lFiltroIdioma)
             
             IF LEFT(EEA->EEA_TIPDOC,1) == "3"
                EEA->(dbSkip())
                Loop
             Endif 

             IF EEA->EEA_ATIVO == "2"     //NCF - 07/07/2017
                EEA->(dbSkip())
                Loop
             Endif                                        
          
             Work2->(dbAppend())
             
             Work2->EE1_DOCUM  := EEA->EEA_COD
             Work2->EE1_FASE   := EEA->EEA_FASE
             Work2->EE1_TIPDOC := EEA->EEA_TIPDOC
             Work2->WK_DESDOC  := EEA->EEA_TITULO
             Work2->TRB_ALI_WT := "EE1"
             Work2->TRB_REC_WT := EE1->(Recno())
             IF Work1->(dbSeek(Work2->EE1_DOCUM))
                Work2->WKMARCA   := cMarca
                Work2->EE1_ORDEM := Work1->EE1_ORDEM
             Endif
             EEA->(dbSkip())
          ENDDO 
          
          IF !lFiltroIdioma
             Exit
          Endif
          
          IF CIDIOMA <> AVKEY(CSXBID,"EEA_IDIOMA")
             CIDIOMA := AVKEY(CSXBID,"EEA_IDIOMA")
             Loop 
          Else  
             Exit   
          Endif
          IF !Empty(cIdioma)
             cIdioma := AvKey("","EEA_IDIOMA")
          Endif
      NEXT
      EEA->(dbSetOrder(1))
      
      IF Work2->(EasyReccount("Work2")) == 0
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
Funcao      : AS120GrvEE1
Parametros  : Nenhum
Retorno     : nil
Objetivos   : Grava EE1 com informacoes do Work1
Autor       : Cristiano A. Ferreira
Data/Hora   : 09/06/1999 10:53
Revisao     :
Obs.        :
*/
STATIC Function AS120GrvEE1()

Begin Sequence
   EE1->(dbSeek(xFilial()+TR_ARQ+M->YA_CODGI+Space(AVSX3("EE1_CODCLI",AV_TAMANHO))))

   While EE1->(!Eof()) .And. EE1->EE1_FILIAL == xFilial("EE1") .And.;
         EE1->EE1_PAIS == M->YA_CODGI .And. EE1->EE1_TIPREL == TR_ARQ .And. EE1->EE1_CODCLI == Space(AVSX3("EE1_CODCLI",AV_TAMANHO))

      EE1->(RecLock("EE1",.F.))
      EE1->(dbDelete())
      EE1->(MSUnlock())
      
      EE1->(dbSkip())   
   End   

   Work1->(dbGoTop())
   
   While Work1->(!Eof())

      // Append
      EE1->(RecLock("EE1",.T.))
         
      EE1->EE1_FILIAL := xFilial("EE1")
      EE1->EE1_DOCUM  := Work1->EE1_DOCUM
      EE1->EE1_PAIS   := M->YA_CODGI
      EE1->EE1_TIPREL := TR_ARQ
      EE1->EE1_ORDEM  := Work1->EE1_ORDEM
      EE1->EE1_FASE   := Work1->EE1_FASE
      EE1->EE1_TIPDOC := Work1->EE1_TIPDOC
      
      EE1->(MSUnlock())

      Work1->(dbSkip())
   End
      
End Sequence

Return NIL
              
/*
Funcao      : BuscaDoc(cCod)
Parametros  : cCod := Codigo do Documento
Retorno     : EEA->EEA_TIPDOC
Objetivos   : Busca a descricao do documento
Autor       : Cristiano A. Ferreira
Data/Hora   : 09/06/1999 12:03
Revisao     :
Obs.        :
*/
STATIC Function BuscaDoc(cCod)
Local xRet 

IF EEA->(dbSeek(xFilial("EEA")+cCod))
   // Alterado por Heder M Oliveira - 9/2/1999
   xRet := EEA->EEA_TITULO  //MSMM(EEA->EEA_CODMEM,60,1)
Else
   xRet := Space(60)
Endif

Return xRet

/*
Funcao      : BuscaMsg(cCod)
Parametros  : cCod := CodigoCadastro+TipoMensagem+CodigodaMensagem
Retorno     : Descricao da Mensagem
Objetivos   : Busca a descricao da mensagem
Autor       : Cristiano A. Ferreira
Data/Hora   : 05/07/1999 11:53
Revisao     :
Obs.        :
*/
STATIC Function BuscaMsg(cCod)
Local xRet 

IF EE4->(dbSeek(xFilial("EEA")+cCod))
   xRet := MSMM(EE4->EE4_TEXTO,AVSX3("EE4_VM_TEX",AV_TAMANHO),1)
Else
   xRet := Space(AVSX3("EE4_VM_TEX",AV_TAMANHO))
Endif

Return xRet

/*
Funcao      : AS120Msg
Parametros  : cAlias := Alias do arquivo
              nReg := Numero do registro
              nOpc := 2 - Visualizar
                      3 - Incluir
                      4 - Alterar
                      5 - Excluir
Retorno     : nil
Objetivos   : Selecao de Mensagens
Autor       : Cristiano A. Ferreira
Data/Hora   : 05/07/1999 11:50
Revisao     :
Obs.        :
*/
STATIC Function AS120Msg(cAlias,nReg,nOpc)

Local oDlg
Local aCpos := { {"WKMARCA",""," "},;
                 {{|| Work3->EE4_COD},"",STR0006},; //"Código"
                 {{|| Work3->EE4_TIPMEN},"",STR0014},; //"Tipo Msg."
                 {{|| BuscaMsg(Work3->EE4_COD+Work3->EE4_TIPMEN+M->YA_IDIOMA)},"",STR0015}} //"Mensagem"

Local i, bOk, bCancel, nOpcao := 0
Local xValue, oMS

Local bOldBlock := bEndDialog

bEndDialog := {|| nOpcao := 3, If(type("oDlg")=="O",oDlg:End(),) }

Begin Sequence

   IF Empty(M->YA_IDIOMA)
      HELP(" ",1,"AVG0005006") //MsgStop("Para selecionar os paises, é necessário informar o idioma.","Atenção")
      Break
   Endif

   M->YA_IDIOMA := Left(M->YA_IDIOMA,AVSX3("YA_IDIOMA")[AV_TAMANHO])

   IF Work3->(EasyReccount("Work3")) == 0
      // *** Grava Work3 com os registros do EE4 ...
      AS120GrvW3()

      IF Work3->(EasyReccount("Work3")) == 0
	     HELP(" ",1,"AVG0000062")
         Break
      Endif
   Endif

   Work3->(dbGotop())

   While .t.
      aTela := {}
      aGets := {}
      nOpcao := 0
                     
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
     
   EnChoice( cAlias, nReg, nOpc,,,,,PosDlgUp(oDlg))

   oMS := MsSelect():New("Work3","WKMARCA",,aCpos,@lInverte,@cMarca,PosDlgDown(oDLG))

   IF nOpc == 2 .Or. nOpc == 5 // Visualizacao ou Exclusao
      oMS:bAval := {|| .T. }
   Endif

   bOk     := {|| nOpcao := 1, oDlg:End() }
   bCancel := {|| nOpcao := 0, oDlg:End() }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)

      IF nOpcao == 3 //Refresh
         // Fecha a janela para reconstruir objetos ...
         IF Work3->(EasyReccount("Work3")) == 0
            // *** Grava Work3 com os registros do EE4 ...
            AS120GrvW3()
            
            IF Work3->(EasyReccount("Work3")) == 0
	           HELP(" ",1,"AVG0000062")
               Break
            Endif
         Endif
      
         Work3->(dbGotop())      
         Loop
      Endif

   IF nOpcao == 0
      Break
   Endif
      
      Exit
   Enddo
        
End Sequence

Return NIL

/*
Funcao      : MarkAll
Parametros  : cAlias,oMsSelect
Retorno     : NIL
Objetivos   : Marca/Desmarca Todos
Autor       : Jeferson Barros Jr.
Data/Hora   : 02/08/2002 17:09
Obs.        : 
*/
*--------------------------------*
Function MarkAll(cAlias,oMsSelect)
*--------------------------------*
Local cFlag, nRecNo:=0

Begin Sequence
   If Empty(cAlias)
      Break
   EndIf

   cFlag  := IF(!Empty((cAlias)->WKMARCA),Space(2),cMarca)
   nRecNo := (cAlias)->(RecNo())
   nOrdem := 1

   (cAlias)->(dbGotop())
   (cAlias)->(dbEval({|| (cAlias)->WKMARCA := cFlag, IF(!Empty(cFlag),(cAlias)->EE1_ORDEM := Str(nOrdem++,AVSX3("EE1_ORDEM",AV_TAMANHO)),)},{|| .T. }))
   (cAlias)->(dbGoTo(nRecNo))
   
   oMsSelect:oBrowse:Refresh()

End Sequence

Return NIL

/*
Funcao      : AS120GrvMsg()
Parametros  : nenhum
Retorno     : NIL
Objetivos   : Grava EE1 com dados do work3
Autor       : Cristiano A. Ferreira
Data/Hora   : 05/07/1999 10:51
Revisao     :
Obs.        :
*/
STATIC Function AS120GrvMsg()

EE1->(dbSeek(xFilial()+TR_MEN+M->YA_CODGI))
   
While EE1->(!Eof()) .And. EE1->EE1_FILIAL == xFilial("EE1") .And.;
      EE1->EE1_PAIS == M->YA_CODGI .And. EE1->EE1_TIPREL == TR_MEN

   EE1->(RecLock("EE1",.F.))
   EE1->(dbDelete())
   EE1->(MSUnlock())
      
   EE1->(dbSkip())   
Enddo

Work3->(dbGoTop())

While ! Work3->(Eof())

   IF Work3->WKMARCA != cMarca
      Work3->(dbSkip())
      Loop
   Endif

   // Append
   EE1->(RecLock("EE1",.T.))
   
   EE1->EE1_FILIAL := xFilial("EE1")
   EE1->EE1_DOCUM  := Work3->EE4_COD
   EE1->EE1_PAIS   := M->YA_CODGI
   EE1->EE1_TIPREL := TR_MEN
   EE1->EE1_TIPMEN := Left(Work3->EE4_TIPMEN,1)

   EE1->(MSUnlock())

   Work3->(dbSkip())
End
     
Return NIL

/*
Funcao      : AS120GrvW3()
Parametros  : nenhum
Retorno     : NIL
Objetivos   : Grava Work3 com dados do EE4
Autor       : Cristiano A. Ferreira
Data/Hora   : 05/07/1999 10:51
Revisao     :
Obs.        :
*/
STATIC Function AS120GrvW3()
Local nOrdEE1:=EE1->(INDEXORD())
EE1->(DBSETORDER(1))

EE4->(dbSeek(xFilial()))

While ! EE4->(Eof()) .And. EE4->EE4_FILIAL == xFilial("EE4")
   IF EE4->EE4_IDIOMA != M->YA_IDIOMA
      EE4->(dbSkip())
      Loop
   Endif

   Work3->(dbAppend())
   
   AvReplace("EE4","Work3")
   Work3->TRB_ALI_WT:= "EE4"
   Work3->TRB_REC_WT:= EE4->(Recno())
   /*
   For i:=1 to Work3->(FCount())   
      bBlock := FieldWBlock(Work3->(FieldName(i)),Select("Work3"))
      xValue := EE4->( FieldGet(FieldPos(Work3->(FieldName(i)))) )
      
      Eval(bBlock,xValue)
   Next
   */

   IF EE1->(dbSeek(xFilial()+TR_MEN+M->YA_CODGI+EE4->EE4_COD+Left(EE4->EE4_TIPMEN,1)))
      Work3->WKMARCA := cMarca
   Endif

   EE4->(dbSkip())
Enddo

EE1->(DBSETORDER(nOrdEE1))
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AS120GAC  ºAutor  ³Andre Veiga         º Data ³  25/02/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a manutencao no cadastro de paises                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGAC / EECAS120                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AS120GAC( cAlias, nReg, nOpc )
Local cFiltro	 	:= ""
Local lRet			:= .T.
Local cIndex	 	:= CriaTrab(Nil,.F.)
Local cKey	 		:= IndexKey()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a funcao de gravacao                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3	// Se inclusao
	Begin Transaction
	AxInclui(cAlias,nReg,nOpc,/*aAcho*/,/*cFunc*/,/*aCpos*/,/*TudOk*/,/*lF3*/,/*cTransact*/,/*aButtons*/,/*aParam*/,/*aRotAuto*/,/*lVirtual*/)
	End Transaction
ElseIf nOpc == 4	// Se alteracao
	Begin Transaction
	AxAltera(cAlias,nReg,nOpc,/*aAcho*/,/*aCpos*/,/*nColMens*/,/*cMensagem*/,/*TudOk*/,/*cTransact*/,/*cFunc*/,/*aButtons*/,/*aParam*/,/*aRotAuto*/,/*lVirtual*/)
	End Transaction
ElseIf nOpc == 5	// Se exclusao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa se o codigo do grupo estah sendo utilizado na publicacao. Se   ³
	//³ afirmativo nao permite a exclusao.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFiltro := "JM0->JM0_FILIAL == '" + xFilial("JM0") + "' .AND. JM0->JM0_PAIS == '" + SYA->YA_CODGI + "'"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona o JM0 e cria os indices                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cIndex	 	:= CriaTrab(Nil,.F.)
	dbSelectArea( "JM0" )
	dbSetorder( 1 )
	cKey	 	:= IndexKey()
	
	IndRegua( "JM0", cIndex, cKey,, cFiltro, STR0022 )		//"Selecionando registros..."
	dbGoTop()
	If !Eof()
		lRet := .F.
	Else
		lRet := .T.
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Arquivo Temporario e Restaura os Indices Ativos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "JM0" )
	Set Filter To
	RetIndex( "JM0" )
	dbSetOrder( 1 )
	If File(cIndex+TEOrdBagExt())
		Ferase(cIndex+TEOrdBagExt())
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui o registro se passou pela validacao acima           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If AxVisual(cAlias,nReg,nOpc) == 1
			Begin Transaction
			RecLock( "SYA", .F. )
			dbDelete()
			MsUnlock()
			End Transaction
		Endif
	Else
		MsgStop(STR0023) //"Operação inválida. Este código de país está sendo utilizado na tabela de publicações."
	Endif
	
Endif

Return Nil

/*
Funcao       : AS120PEVALID(nOpc)
Parametros   : Nenhum
Retorno      : Nil
Objetivos    : Executar ponto de entrada no CodBlock bOK
Autor        : Lucas Raminelli LRS
Data/Hora    : 21/08/2018
*/
Function AS120PEVALID(nOpc)


IF(EasyEntryPoint("EECAS120"),Execblock("EECAS120",.F.,.F.,{"VALID_GRAVACAO",nOpc}),)

Return lRetPE

*-------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAS120.PRW                                            *
*-------------------------------------------------------------------------*


