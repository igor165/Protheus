#INCLUDE "Eicpo570.ch"
#INCLUDE "AVERAGE.CH"
/*-----------------------------------------------------------------------------
Funcao      : EICPO570
Parametros  :  
Retorno     : 
Objetivos   : Controle da Manutenção das Proformas Invoices.
Autor       : Thiago Rinaldi Pinto
Data        : 14/07/2008
Hora        : 10:30 
Obs.        :  
-----------------------------------------------------------------------------*/
Function EICPO570()    


Private cCadastro := STR0007
  
   
Private aRotina := {{ STR0001 , "AxPesqui" , 0, 1},;
                    { STR0002 , "PO570MAN", 0, 2},;
                    { STR0003 , "PO570MAN", 0, 3},;
                    { STR0004 , "PO570MAN", 0, 4},;
                    { STR0005 , "PO570MAN", 0, 5},;
                    { STR0006 ,"EVAL({||EICPO557(.T.)})", 0 , 0} }  //** BHF - 18/12/08
                       
   
SET DELETED ON

mBrowse(6,1,22,75,"EYZ")

Return .T.

/*-----------------------------------------------------------------------------
Funcao      : PO570MAN
Parametros  : cAlias: Alias da tabela a ser usada
              nReg  : nº do Registro que estava selecionado no MBrowse
              nOpc  : opção sobre o que a função irá executar.
Retorno     :
Objetivos   : Manutenção de Proformas
Autor       : Thiago Rinaldi Pinto
Data        : 14/07/2008
Hora        : 10:30
Obs.        :
-----------------------------------------------------------------------------*/
*----------------------------------------*
Function PO570MAN(cAlias, nReg, nOpc)
*----------------------------------------*   
Local oDlg
Local cTitulo := STR0007
Local lOk := .F.
Local bOk := {|| If(PO570Valid("BOK"),(lOk := .T., oDlg:End()),)}
Local bCancel := {|| oDlg:end()}
Local aButtons := {}
Local cNomFile1
Local aCpoBrowse := {}
Local aCpoAdic := {}
Local i
Local nInc 
Local aOrdEYZ:= {}
Local cPO := "", cProf := ""  // GFP - 09/08/2013

Private aTela[0][0],aGets[0]
Private lIncluir := (nOpc == INCLUIR)
Private lAlterar := (nOpc == ALTERAR)
Private lExcluir := (nOpc == EXCLUIR)
Private aDeletados := {}
Private aHeader := {}
Private aCampos := Array(EW0->(FCount()))

Private lInverte := .F.
Private oBrowse
Private cMarca := GetMark()
   

AADD(aCpoAdic, {"WK_RECNO"  ,"N", 10, 0})
AADD(aCpoAdic, {"WKMARCA"   ,"C",  2, 0})

cNomeFile1 := E_CriaTrab("EW0",aCpoAdic,"WK_EW0")

AADD(aCpoBrowse,{"WKMARCA",,""})
AADD(aCpoBrowse,{"EW0_POSICA" ,"",STR0013})  // STR0013 "Posição"
AADD(aCpoBrowse,{"EW0_COD_I"  ,"",STR0014}) //STR0014 "Código Item"
AADD(aCpoBrowse,{"EW0_QTDE"   ,"",STR0015,AvSx3("EW0_QTDE",AV_PICTURE)}) //STR0015 "Quantidade" 
AADD(aCpoBrowse,{"EW0_SALDO"  ,"",STR0016,AvSx3("EW0_SALDO",AV_PICTURE)}) //STR0016 "Saldo"
   
//Marca e Desmarca Todos
AADD(aButtons,{"LBTIK",{|| Processa({|| MarkAll("WK_EW0",oBrowse)})},"Marca/Desmarca Todos"}) 
   
If nOpc == 3
   For nInc := 1 To EYZ->(FCount())
      M->&(EYZ->(FieldName(nInc))) := CriaVar(EYZ->(FieldName(nInc)))
   Next
Elseif nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5
   For nInc := 1 To EYZ->(FCount())
      M->&(EYZ->(FieldName(nInc))) := EYZ->(FieldGet(nInc))
   Next
Endif

If nOpc != INCLUIR
   EW0->(dbSetOrder(1))
   EW0->(dbSeek(xFilial("EW0")+M->EYZ_PO_NUM+M->EYZ_NR_PRO))
   SW2->(DbSetOrder(1))
   // DFS - 25/05/11 - Inclusão do If, para verificar se encontra o campo. AvKey para chave correta de busca.
   If SW2->(DbSeek(xFilial("SW2") + AvKey(M->EYZ_PO_NUM, "W2_PO_NUM")))
      SoftLock("SW2")
   Endif
   While EW0->(!Eof() .And. EW0_FILIAL+EW0_PO_NUM+EW0_NR_PRO == xFilial()+M->(EYZ_PO_NUM+EYZ_NR_PRO))
      SW3->(DbSetOrder(8))
      If SW3->(DbSeek(xFilial("SW3")+EW0->(EW0_PO_NUM+EW0_POSICA)))
         WK_EW0->(dbAppend())
         AvReplace("EW0","WK_EW0")
         WK_EW0->EW0_SALDO := PO570SLDPRO(WK_EW0->(EW0_PO_NUM+EW0_POSICA), SW3->W3_QTDE)
         WK_EW0->WK_RECNO  := EW0->(RECNO())
         WK_EW0->WKMARCA   := cMarca
      EndIf
      EW0->(dbSkip())
   Enddo
   WK_EW0->(dbGoTop())
Endif

//BAK - 27/04/2011 - comentado para que nao apareça o campo de usuario, não é necessario para a rotina.
//aCpoBrowse:= AddCpoUser(aCpoBrowse,"EW0","2")

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO oMainWnd:nBottom-60,oMainWnd:nRight - 10 OF oMainWnd Pixel
   Enchoice(cAlias, nReg, nOpc,,,,,PosDlgUP(oDlg))
   oBrowse := MsSelect():New("WK_EW0","WKMARCA",,aCpoBrowse,@lInverte,@cMarca,PosDlgDown(oDlg))
   oBrowse:bAval := {|| PO570DETMAN(nOpc) }
Activate MSDIALOG oDlg on Init EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

cPo   := M->EYZ_PO_NUM  // GFP - 09/08/2013
cProf := M->EYZ_NR_PRO  // GFP - 09/08/2013

If lOk .And. (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 5)

   Begin Transaction
      EYZ->(RecLock("EYZ", nOpc == INCLUIR))
      If nOpc == EXCLUIR
         EYZ->(dbDelete())
         WK_EW0->(dbGoTop())
         While WK_EW0->(!Eof())
            If WK_EW0->WK_RECNO > 0
               EW0->(dbGoTo(WK_EW0->WK_RECNO))
               EW0->(RecLock("EW0",.F.))
               EW0->(dbDelete())
               EW0->(MsUnlock())
            Endif
            WK_EW0->(dbSkip())
         Enddo  
         //Exclusão do nº da Proforma e Data da Proforma da Capa do Pedido - AOM - 05/02/10
         SW2->(DbSetOrder(1))
         If SW2->(DbSeek(xFilial("SW2") + M->EYZ_PO_NUM))
            SW2->(RecLock("SW2",.F.))
            If SW2->W2_NR_PRO == M->EYZ_NR_PRO
               SW2->W2_NR_PRO := ""
               SW2->W2_DT_PRO := CTOD("")
               aOrdEYZ:= SaveOrd({"EYZ"})
               EYZ->(DbSetOrder(1))
               If EYZ->(DbSeek(xFilial("EYZ")+SW2->W2_PO_NUM))  //TRP - 02/03/2013 - Atualizar os campos Proforma e Dt Proforma caso exista outra Proforma.
                  SW2->W2_NR_PRO := EYZ->EYZ_NR_PRO
                  SW2->W2_DT_PRO := EYZ->EYZ_DT_PRO
               Endif
               RestOrd(aOrdEYZ,.T.)
            Endif
            SW2->(MsUnlock())    
         EndIf
         EYZ->(DbGotop())
      Else
         AvReplace("M", "EYZ")
         EYZ->EYZ_FILIAL := xFilial("EYZ")  
         //Inclusão/Alteração do nº da Proforma e Data da Proforma da Capa do Pedido - AOM - 05/02/10
         SW2->(DbSetOrder(1))
         If SW2->(DbSeek(xFilial("SW2") + M->EYZ_PO_NUM))
            SW2->(RecLock("SW2",.F.))
            If Empty(SW2->W2_NR_PRO)
               SW2->W2_NR_PRO := M->EYZ_NR_PRO
            Endif
            If Empty(SW2->W2_DT_PRO)
               SW2->W2_DT_PRO := M->EYZ_DT_PRO
            Endif
            SW2->(MsUnlock())    
         EndIf
         WK_EW0->(dbGoTop())
         While WK_EW0->(!Eof())
            If WK_EW0->WK_RECNO > 0
               EW0->(dbGoTo(WK_EW0->WK_RECNO))
            Endif
            EW0->(RecLock("EW0", WK_EW0->WK_RECNO == 0))
            AvReplace("WK_EW0","EW0")
            EW0->EW0_FILIAL := xFilial("EW0")
            EW0->EW0_NR_PRO := M->EYZ_NR_PRO
            EW0->(MsUnlock())
            WK_EW0->(DbSkip())
         Enddo

         For i := 1 To Len(aDeletados)
            EW0->(dbGoTo(aDeletados[i]))
            EW0->(RecLock("EW0",.F.))
            EW0->(dbDelete())
            EW0->(MsUnlock())
         Next
      Endif
      EYZ->(MsUnlock())
      PO570ATUPO(nOpc, cPO,cProf)  // GFP - 09/08/2013
   End Transaction
Endif
WK_EW0->(E_EraseArq(cNomeFile1))

SW2->(MsUnlockAll())  

//TDF - 09/11/2012
If EasyEntryPoint("EICPO570")
   ExecBlock("EICPO570",.F.,.F.,"FIM_PO570MAN")
EndIf

Return

*------------------------------*
Function PO570DETMAN(nOpc)
*------------------------------*   
Local oDlg
Local cTitulo := STR0008
Local lOk := .F.
Local nInc
Local bOk := {|| if(Obrigatorio(aGets,aTela),(lOk := .T., oDlg:End()),)}
Local bCancel := {|| oDlg:end()}
Local nValorGrv := 0

Private aTela[0][0],aGets[0]

Begin Sequence

   If !Empty(WK_EW0->WKMARCA)
      WK_EW0->WKMARCA := ""
      WK_EW0->EW0_SALDO := WK_EW0->EW0_SALDO + WK_EW0->EW0_QTDE
      WK_EW0->EW0_QTDE := 0
      Break
   EndIf
   
   If nOpc == INCLUIR .Or. nOpc == ALTERAR
      aAltera := Nil
   ElseIf nOpc == EXCLUIR .Or. nOpc == VISUALIZAR
      aAltera := {}
   EndIf
   
   For nInc := 1 To WK_EW0->(FCount())
      M->&(WK_EW0->(FieldName(nInc))) := WK_EW0->(FieldGet(nInc))
   Next

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,636 OF oMainWnd Pixel
      Enchoice("EW0", , ALTERAR,,,,,PosDlg(oDlg), aAltera,,,,,,,.T.) //LRS - 27/02/2018
   Activate MSDIALOG oDlg on Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED

   nValorGrv := M->EW0_QTDE - WK_EW0->EW0_QTDE
   
   If lOk .And. (nOpc == ALTERAR .Or. nOpc == INCLUIR)
      AvReplace("M", "WK_EW0")
      WK_EW0->EW0_SALDO  := WK_EW0->EW0_SALDO - nValorGrv
      WK_EW0->WKMARCA    := cMarca
   Endif
   
   oBrowse:oBrowse:Refresh()

End Sequence

Return

*----------------------------------------*
Static Function MarkAll(cAlias,oMsSelect) 
*----------------------------------------*
Local nRecNo:=0
Local lMarca := Empty((cAlias)->WKMARCA)

Begin Sequence
   
   nRecNo := (cAlias)->(RecNo())
   (cAlias)->(DbGoTop())
   While (cAlias)->(!Eof())
      If lMarca .And. Empty((cAlias)->WKMARCA)
         (cAlias)->WKMARCA   := cMarca
         (cAlias)->EW0_QTDE  := (cAlias)->EW0_SALDO
         (cAlias)->EW0_SALDO := 0
      ElseIf !lMarca .And. !Empty((cAlias)->WKMARCA)
         (cAlias)->WKMARCA   := Space(2)
         (cAlias)->EW0_SALDO := (cAlias)->EW0_SALDO + (cAlias)->EW0_QTDE
         (cAlias)->EW0_QTDE  := 0
      EndIf
      (cAlias)->(DbSkip())
   EndDo
   (cAlias)->(dbGoTo(nRecNo))
   
   oBrowse:oBrowse:Refresh()

End Sequence

Return Nil 

*----------------------------------*
Function PO570Valid(cCampo) 
*----------------------------------*
Local lRet:= .T.
Local nValorAux:= 0

Begin Sequence

   Do Case

      Case cCampo == "EYZ_PO_NUM"

         SW2->(DbSetOrder(1))
         If !SW2->(DbSeek(xFilial("SW2") + M->EYZ_PO_NUM))
            MsgAlert(STR0009)
            lRet:= .F.  
            Break
         Endif
         
         //Busca todos os itens do P.O. informado
         BuscaItemPo()
         
      Case cCampo == "EYZ_NR_PRO"

         EYZ->(DbSetOrder(1))
         If EYZ->(DbSeek(xFilial("EYZ") + M->EYZ_PO_NUM + M->EYZ_NR_PRO))
            MsgInfo(STR0010)
            lRet:= .F.
            Break
         Endif   

   
      Case cCampo == "EW0_QTDE"   
         
         nValorAux := M->EW0_QTDE - WK_EW0->EW0_QTDE
         
         If nValorAux > WK_EW0->EW0_SALDO
            MsgInfo(STR0011)
            lRet:= .F.
            Break
         Endif
      
      Case cCampo == "BOK"
         If !Obrigatorio(aGets,aTela)
            lRet := .F.
            Break
         EndIf
         If lExcluir .And. !ApMsgYESNO(STR0012)
            lRet := .F.
            Break
         EndIf
         
   EndCase

End Sequence

Return lRet

*-----------------------------*
Static Function BuscaItemPo()
*-----------------------------*
Local aOrd := SaveOrd("SW3")

   SW3->(DbSetOrder(1))
   If SW3->(DbSeek(xFilial("SW3") + M->EYZ_PO_NUM ))
      If SW2->(!Eof()) .AND. SW2->(!Bof())
         SW2->(MsUnlockAll())
      Endif
      SW2->(DbSetOrder(1))
      // DFS - 25/05/11 - Inclusão do If, para verificar se encontra o campo. AvKey para chave correta de busca.
      If SW2->(DbSeek(xFilial("SW2") + AvKey(M->EYZ_PO_NUM, "W2_PO_NUM")))
         SoftLock("SW2")
      Endif
      WK_EW0->(avzap())
      Do While SW3->(!Eof()) .AND. xFilial("SW3") == SW3->W3_FILIAL .AND. SW3->W3_PO_NUM == M->EYZ_PO_NUM
         If SW3->W3_SEQ = 0
            WK_EW0->(dbAppend())
            WK_EW0->WKMARCA    := cMarca
            WK_EW0->EW0_POSICA := SW3->W3_POSICAO                    
            WK_EW0->EW0_COD_I  := SW3->W3_COD_I                      
            WK_EW0->EW0_PO_NUM := SW3->W3_PO_NUM 
            WK_EW0->EW0_QTDE   := PO570SLDPRO(WK_EW0->(EW0_PO_NUM+EW0_POSICA), SW3->W3_QTDE)
            WK_EW0->EW0_SALDO  := 0
         Else
            SW3->(DbSkip())
            Loop
         Endif
         SW3->(DbSkip())
      Enddo
   Endif
   WK_EW0->(DbGoTop())
   oBrowse:oBrowse:Refresh()

RestOrd(aOrd, .T.)

Return Nil 

*------------------------------------*
Function PO570SLDPRO(cChave, nW3_QTD)
*------------------------------------*
Local aOrd := SaveOrd({"EW0", "SW2", "SW3"})
Local nSaldo:= 0
Local nAcumula:= 0 

EW0->(DbSetOrder(2))
If EW0->(DbSeek(xFilial("EW0")+cChave))
   
   Do While EW0->(!Eof() .And. EW0_FILIAL+EW0_PO_NUM+EW0_POSICA == xFilial()+cChave)

      nAcumula+= EW0->EW0_QTDE

      EW0->(DbSkip())
   Enddo    
   
   nSaldo:= nW3_QTD - nAcumula
//acb - 13/04/2010 - Tratamento incluido para quando houver data da proforma na capa da PO
// sem cadastro na manutenção de proforma, indica ao sistema que possui proforma
else 

   SW3->(Dbsetorder(8))//W3_FILIAL+W3_PO_NUM+W3_POSICAO
   SW3->(DbSeek(xFilial("SW3")+cChave))
   
   SW2->(DbSetOrder(1))//W2_FILIAL+W2_PO_NU
   If SW2->(DbSeek(xFilial("SW2")+SW3->W3_PO_NUM)) .and. SW2->W2_PO_NUM == SW3->W3_PO_NUM

      //WFS - 19/01/12
      //if empty(SW2->W2_DT_PRO) 
         nSaldo := nW3_QTD 
      //EndIf                
   
   EndIf

Endif

RestOrd(aOrd, .T.)

Return nSaldo

/*
Função.....: PO570ATUPO
Parametros.: nOpc - Tipo de manutenção / cPO - Numero PO / cProf - Numero Proforma
Retorno....: NIL
Objetivo...: Atualizar campos W2_NR_PRO e W2_DT_PRO com o numero e data da Proforma salva.
Autor......: Guilherme Fernandes Pilan - GFP
Data/Hora..: 09/08/2013 - 11:22
*/
*------------------------------*
Function PO570ATUPO(nOpc, cPO, cProf)
*------------------------------* 
Local nRecno := EYZ->(Recno())
Local lTemProf := .F.

If nOpc <> INCLUIR .AND. nOpc <> ALTERAR
   Return NIL
EndIf

SW2->(DbSetOrder(1))
EYZ->(DbSetOrder(1))

If EYZ->(DbSeek(xFilial("EYZ")+cPO))
   Do While EYZ->(!Eof()) .AND. EYZ->EYZ_FILIAL == xFilial("EYZ") .AND. EYZ->EYZ_PO_NUM == cPO
      If EYZ->EYZ_NR_PRO <> cProf
         lTemProf :=  .T.
         Exit
      EndIf
      EYZ->(DbSkip())
   EndDo
EndIf

EYZ->(DbGoTo(nRecno))
If SW2->(DbSeek(xFilial("SW2")+EYZ->EYZ_PO_NUM))
   If SW2->(RecLock("SW2",.F.))
      SW2->W2_NR_PRO := If(lTemProf,"Vários",EYZ->EYZ_NR_PRO)
      SW2->W2_DT_PRO := EYZ->EYZ_DT_PRO      
      SW2->(MsUnlock())
   EndIf
EndIf

Return NIL
