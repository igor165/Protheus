#INCLUDE "EECAS102.ch"
/*
Programa : EECAS102
Autor    : Alex Wallauer
Data     : 24/06/99
Revisao  : Cristiano A. Ferreira / CAF 18/04/2000 Protheus
Uso      : Permitir manutencao Instr. Neg com varios paises
*/

#include "EEC.cH"

#COMMAND E_RESET_AREA => EE1->(DBSETORDER(2)) ; TRB->(E_EraseArq(cNomArq))

/*
Funcao      : EECAS102
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Montar browse
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*/
Function EECAS102()

Local lRet:=.T.,cOldArea:=select(),cAlias:="EEE"

Private cCadastro := AVTITCAD("EEE") //"Instrumento de Negociação"
Private aRotina   := MenuDef()
Begin Sequence
   
   EEE->(DBSETORDER(1)) 
   mBrowse( 6, 1,22,75,cAlias)
   
End Sequence

dbselectarea(cOldArea)

Return lRet                   

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 24/01/07 - 11:24
*/
Static Function MenuDef()
Local aRotAdic := {}
Local aRotina :=  { { STR0001, "AxPesqui"  , 0 , PESQUISAR},; //"Pesquisar"
                    { STR0002, "AS102MAN"  , 0 , VISUALIZAR},; //"Visualizar"
                    { STR0003, "AS102MAN"  , 0 , INCLUIR},; //"Incluir"
                    { STR0004, "AS102MAN"  , 0 , ALTERAR},; //"Alterar"
                    { STR0005, "AS102MAN"  , 0 , EXCLUIR,3} } //"Excluir"

// P.E. utilizado para adicionar itens no Menu da mBrowse
If EasyEntryPoint("EAS102MNU")
   aRotAdic := ExecBlock("EAS102MNU",.f.,.f.)
   If ValType(aRotAdic) == "A"
      AEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf
EndIf

Return aRotina

/*
Funcao      : AS102MAN
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Manutencao com enchoice
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*/
Function AS102MAN(cAlias,nReg,nOpc)

Local lRet:=.T.,cOldArea:=select(),oDlg,nInc,bVal_OK
Local lGravaOK:=.T.,nOpcA:=3, bCancel

Local aButtons := { {"EDIT"   ,{|| AS102EE1MAN(INC_DET) },STR0003},; //"Incluir"
                     {"EXCLUIR" ,{|| AS102EE1MAN(EXC_DET) },STR0005} } //"Excluir"

Local aCampoEE1:={ {{||TRB->EE1_PAIS} , "", STR0006     } ,; //"Pais"
                   {{||TRB->EE1_DESCR}, "", STR0007} } //"Descricao"
                    

Private aTela[0][0],aGets[0],nUsado:=0
Private aDeletados:={}
Private aCampos,aUsado,aHeader[0],cNomArq,oObj

Begin Sequence

   aCampos:=ARRAY(EE1->(FCOUNT()))
   aSemSX3:= {{"EE1_RECNO","N",07,0}}
   AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
   AADD(aSemSX3,{"TRB_REC_WT","N",10,0})
   cNomArq:=E_CriaTrab("EE1",aSemSX3)
   IndRegua("TRB",cNomArq+TEOrdBagExt(),"EE1_PAIS")
                              
   //OAP - Adequação para que os campos de usuário sejam mostrados na rotina  
   aUsado := AddCpoUser(aUsado,"EE1","1")

   IF nOpc == INCLUIR
      //CRIAR VARIAVEIS
      For nInc := 1 TO (cAlias)->(FCount())
          M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next nInc
      
      bVal_OK:={||If(Obrigatorio(aGets,aTela),(nOpcA:=1,oDlg:End()),nOpca:=0)}
   Else
      For nInc := 1 TO (cALIAS)->(FCount())
          M->&((cAlias)->(FIELDNAME(nInc))) := (cALIAS)->(FIELDGET(nInc))
      Next nInc
      
      If nOpc = VISUALIZAR
         bVal_OK:={||oDlg:End()}
         AS102GRTRB()
      ElseIf nOpc==ALTERAR
         bVal_OK:={||If(Obrigatorio(aGets,aTela),(nOpcA:=2,oDlg:End()),nOpca:=0)}
         AS102GRTRB()
      ElseIf nOpc = EXCLUIR
         /*
         AMS - 05/04/2005. Consistência na exclusão do registro para não permitir quando estiver relacionada
                           com outras tabelas.
         */
         If !IntegRef("EEE")
            Break
         EndIf
         bVal_OK:={||nOpca:=0,AS102MANE(),oDlg:End()}
         AS102GRTRB()
      EndIf
      
      TRB->(dbGoTop())
   Endif

   //OAP - Adequação para a inclusão de campos criados pelo usuário na rotina
   aCampoEE1 := AddCpoUser(aCampoEE1,"EE1","5","TRB") 
   While ( nOpca>=3 )
      nOpcA:=0
      aTela := {}
      aGets := {}
      
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
          
         EnChoice( cAlias, nReg, nOpc, , , , ,PosDlgUp(oDlg))
         
         oObj:=MsSelect():New("TRB",,,aCampoEE1,,,PosDlgDown(oDlg))
         
         bCancel := {|| oDlg:End() }

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bVal_Ok,bCancel,,IF(!Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),aButtons,nil))

      Do Case
         Case nOpca==1
            Begin Transaction
               Processa({||lGravaOk:=AS102Grava(.T.)})
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
              EEE->(dbgoto(nReg))  //soh p/confirmar
              Processa({||lGravaOk:=AS102Grava(.F.)})
      EndCase

   Enddo
End Sequence

E_RESET_AREA

dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AS102MANE
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Exclusao de dados
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*/
Static Function AS102MANE()

Local lRet:=.T.,cOldArea:=select(),cFilE1:=Xfilial("EE1")

Begin Sequence

   if Msgnoyes(OemtoAnsi(STR0008),Oemtoansi(STR0009)) //"Confirma Exclusão?"###"Atenção"

      Reclock("EEE",.F.)

      EE1->(DBSETORDER(2))
      If EE1->(DBSEEK(cFilE1+TR_INS+EEE->EEE_INSCOD))
         DO While !EE1->(EOF())             .AND. ; 
                   EE1->EE1_FILIAL == cFilE1.AND. ; 
                EE1->EE1_TIPREL == TR_INS.AND. ;
                   EE1->EE1_DOCUM  = EEE->EEE_INSCOD
       
            RECLOCK("EE1",.F.)
            EE1->(DBDELETE())
            EE1->(MsUnlock())
            EE1->(DBSKIP())

         Enddo
      EndIf
      
      EEE->(DBDELETE())
      EEE->(MsUnlock())
   endif
   
End Sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AS102DELEE1
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : 
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*/
/*
Static Function AS102DELEE1()

Local lRet:=.T.,cOldArea:=select()

Begin sequence
  If (TRB->(EOF()) .AND. TRB->(BOF()))
     HELP(" ",1,"AVG0005002") //MSGSTOP(OEMTOANSI("NÆo existem paises para serem deletadas."),"Aviso")
     lRet:=.F.
  EndIf
End sequence

dbselectarea(cOldArea)

Return lRet
*/
/*
Funcao      : AS102EE1MAN
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Manutencao com enchoice
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*/
Static Function AS102EE1MAN(nTipo)

Local lRet:=.T.,cOldArea:=select(),oDlg,nInc,nOpcA:=0,cNewtit
Local aJFEnchoice:={"EE1_PAIS","EE1_DESCR"}
Local nRec
Local w := 0                      
Local k := 0

Private aUsado := Array(0)
Private aTela[0][0],aGets[0],nUsado:=0
Private cDescrPais

Begin Sequence

   If nTipo # INC_DET .and. TRB->(EOF()) .AND. TRB->(BOF())
      HELP(" ",1,"AVG0005004") //MSGINFO(OemToAnsi("Não existem Paises"),"Aviso")
      BREAK
   EndIf
   
   //OAP - 30/10/2010 - Inclusão de campo criado pelo usuário.
   aJFEnchoice := AddCpoUser(aJFEnchoice,"EE1","1")
   
   IF nTipo == INC_DET   
      
      //OAP - Adequação para que os campos inseridos pelo usuário sejam inseridos no processo de inclusão.   
      For k := 1 To ("EE1")->(FCount())
        M->&(("EE1")->(FieldName(k))) := CRIAVAR(("EE1")->(FieldName(k)))
      Next k

   //   M->EE1_PAIS := CriaVar("EE1_PAIS")
   //   M->EE1_DESCR:= CriaVar("EE1_DESCR")
   Else
      nRec := TRB->(RecNo()) 
      
      //OAP - Adequação para que os campos inseridos pelo usuário sejam visuais no processo de exclusão.
      For k := 1 To Len(aJFEnchoice)        
         M->&(EE1->(aJFEnchoice[k])) := TRB->&(EE1->(aJFEnchoice[k]))
      Next k
      
      //M->EE1_PAIS := TRB->EE1_PAIS
      //M->EE1_DESCR:= TRB->EE1_DESCR
      cDescrPais := TRB->EE1_DESCR
   EndIf
   
   cNewTit := STR0010+M->EEE_DESC //"Pais do Instr.: "

   DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
                           
      
      EnChoice("EE1",,3,,,,aJFEnchoice,PosDlg(oDlg),IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aJFEnchoice),3)
      //EnChoice("EE1",,3,,,,aJFEnchoice,PosDlg(oDlg),IF(Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)
      @ 500,048   BUTTON oBtnDes PROMPT STR0011 SIZE 50,12 //"ok"
   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,IF(AS102VALSF(nTipo,nRec),oDlg:End(),nOpcA:=0)},{||oDlg:End()})
  
   If nOpcA # 0
      If nTipo == INC_DET
         TRB->(DBAPPEND())
      Endif
             
      If !Str(nTipo,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)
         AvReplace("M","TRB")
         TRB->EE1_DOCUM  := M->EEE_INSCOD
         TRB->EE1_DESCR  := Posicione("SYA",1,xFilial("SYA")+AvKey(M->EE1_PAIS,"YA_CODGI"),"YA_DESCR")
         //OAP - Adequação para que os campos de usuário sejam mostrados na rotina
         For w := 1 To Len(aUsado)
            TRB->&(EE1->(aUsado[k])) := M->&(EE1->(aUsado[k]))
         Next w
      EndIf
      
      oObj:oBrowse:Refresh()
   EndIf
   
End Sequence
  
dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AS102VALSF
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Consistir os dados
Autor       : 
Data/Hora   : 
Revisao     :
Obs.        :
*/
Static Function AS102VALSF(nTipo,nRecno)

Local lRet:=.T.,cOldArea:=select()

Begin Sequence

   If nTipo == INC_DET .OR. nTipo = ALT_DET
      lRet:=Obrigatorio(aGets,aTela)
   ElseIf nTipo == EXC_DET
      TRB->(DBGOTO(nRecno))
      If MsgNoYes(STR0012,STR0013) //'Confirma Exclusão ?'###'Atenção'
         If TRB->EE1_RECNO # 0
            AADD(aDeletados,TRB->EE1_RECNO)
         EndIf
         TRB->(dbDelete())
         TRB->(dbSkip(-1))
         IF TRB->(Bof())
            TRB->(dbGotop())
         Endif
      EndIf
   EndIf

End Sequence

dbselectarea(cOldArea)

Return lRet

*----------------------------------------------------------------------------*
Static Function AS102GRTRB()
*----------------------------------------------------------------------------*
Local lRet:=.T.,cOldArea:=select(),cFilE1:=XFILIAL("EE1")
Local y := 0 //FSM 03/04/11
Begin sequence

   EE1->(DBSETORDER(2))
   SYA->(DBSETORDER(1))
   If EE1->(DBSEEK(cFilE1+TR_INS+EEE->EEE_INSCOD))
      DO While !EE1->(EOF())             .AND. ; 
                EE1->EE1_FILIAL == cFilE1.AND. ; 
                EE1->EE1_TIPREL == TR_INS.AND. ;
                EE1->EE1_DOCUM  = EEE->EEE_INSCOD
         SYA->(DBSEEK(xFilial("SYA")+EE1->EE1_PAIS)) 
         TRB->(DBAPPEND())
         TRB->EE1_DOCUM  := EE1->EE1_DOCUM
         TRB->EE1_PAIS   := EE1->EE1_PAIS
         TRB->EE1_DESCR  := SYA->YA_DESCR
         //OAP - Adequação para que os campos de usuário sejam mostrados na rotina 
         For y := 1 To Len(aUsado)
            TRB->&(EE1->(aUsado[y])) := EE1->&(EE1->(aUsado[y]))
         Next y            
         TRB->EE1_RECNO  := EE1->(RECNO())
         TRB->TRB_ALI_WT := "EE1"
         TRB->TRB_REC_WT := EE1->(Recno())
         EE1->(DBSKIP())
      Enddo
   Else
      lRet:=.F.
   EndIf

End sequence

dbselectarea(cOldArea)

Return lRet

*----------------------------------------------------------------------------*
Static Function AS102Grava(lGrava)
*----------------------------------------------------------------------------*
Local lRet:=.T.,cOldArea:=select(),nInc

Begin sequence

ProcRegua((LEN(aDeletados)+TRB->(LASTREC())))

E_Grava("EEE",lGrava)

For nInc:=1 to LEN(aDeletados)
   EE1->(DBGOTO(aDeletados[nInc]))
   IncProc()
   RecLock("EE1",.F.)
   EE1->(DBDELETE())
   EE1->(MsUnlock())
Next nInc

TRB->(DBGOTOP())
DO While ! TRB->(EOF())

   If !lGrava .AND. TRB->EE1_RECNO # 0
      EE1->(DBGOTO(TRB->EE1_RECNO))
      RecLock("EE1",.F.)
   Else
      RecLock("EE1",.T.)  // bloquear e incluir registro vazio
   EndIf
   IncProc()

  /* EE1->EE1_FILIAL:=xFilial("EE1")
   EE1->EE1_TIPREL:=TR_INS
   EE1->EE1_DOCUM :=TRB->EE1_DOCUM
   EE1->EE1_PAIS  :=TRB->EE1_PAIS   */

   //OAP 
   AvReplace("TRB","EE1")   
   EE1->EE1_FILIAL:=xFilial("EE1")
   EE1->EE1_TIPREL:=TR_INS
   EE1->(MsUnlock())
   TRB->(DBSKIP())

Enddo

End sequence

dbselectarea(cOldArea)

Return lRet

*----------------------------------------------------------------------------*
Function AS102Valid()
*----------------------------------------------------------------------------*
IF TRB->(dbSeek(M->EE1_PAIS))
   HELP(" ",1,"AVG0005003") //MsgStop("Pais já incluido !","Atenção")
   Return  .F.
Endif
Return .T.

*------------------------------------------------------------------------*
* FIM DO PROGRAMA ECCAS102.PRW                                           *
*------------------------------------------------------------------------*
