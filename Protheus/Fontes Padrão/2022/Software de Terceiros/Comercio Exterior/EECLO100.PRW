#include "EEC.CH"
#include "EECLO100.CH"
/*
Programa        : EECLO100.PRW
Objetivo        : Manutencao de Lotes.
Autor           : Osman Medeiros Jr.
Data/Hora       : 29/01/2003 15:51
Obs.            :
Revisao         : 
Data/Hora       : 
*/

#COMMAND E_RESET_AREA => Work_Lote->(E_EraseArq(cArqLote)) ;;
                         Wrk_Lote2->(E_EraseArq(cArqLote2))
                         

/*
Funcao      : EECLO100()
Parametros  : 
Retorno     : .T.
Objetivos   : Executar mbrowse
Autor       : Osman Medeiros Jr.
Data/Hora   : 29/01/2003 15:51
Revisao     : 
Obs.        :
*/
*------------------
Function EECLO100(cAlias,nReg,nOpc)
*------------------              
Local lRet := .T.
Local nSelect := Select(), nInc:=0
Local aOrd := SaveOrd({"EEC","EE9","EE8"})
Local aPos
Local oDlg   
Local nOpcA:=0,lGravaOk:=.F.
Local bCancel := {||nOpcA:=0,oDlg:End()} 
Local bOk     := {||nOpcA:=1,oDlg:End()} 
Local aHDEnchoice:={"EEC_PREEMB","EEC_DTPROC","EEC_IMPORT","EEC_IMPODE",;
                    "EEC_ENDIMP","EEC_END2IM","EEC_FORN","EEC_FORNDE"}
Local lOk
Local cArqLote,cArqLote2
Local aSemSX3

Private aButtons := {}   
Private lInverte := .f.
Private aTela[0][0],aGets[0],nUsado:=0   
Private cMarca := GetMark(), oMsSelect  
Private aCampos:={},aHeader:={}
Private aDelEXI1 := {}
Private aDelEXI2 := {}

Begin Sequence
   aSemSX3 := {{"WK_RECNO" ,"N",7,0}}
   AVUsado("EXI_PREEMB",@aSemSX3)
   AVUsado("EXI_PEDIDO",@aSemSX3)
   AVUsado("EXI_SEQEMB",@aSemSX3)

   aCampos:=Array(EXI->(fCount()))
   cArqLote:=E_CRIATRAB("EXI",aSemSX3,"Work_Lote")  
   IndRegua("Work_Lote",cArqLote+TEOrdBagExt(),"EXI_SEQEMB+EXI_LOTE","AllwayTrue()",;
           "AllwaysTrue()",STR0001)                    //"Processando Arquivo Temporario ..."
           
   aCampos:=Array(EXI->(fCount()))   
   aAdd(aSemSX3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
   cArqLote2:=E_CRIATRAB("EXI",aSemSX3,"Wrk_Lote2")  
   IndRegua("Wrk_Lote2",cArqLote2+TEOrdBagExt(),"EXI_LOTE","AllwayTrue()",;
           "AllwaysTrue()",STR0001)                    //"Processando Arquivo Temporario ..."

   nOpc := VISUALIZAR
   aAdd(aButtons,{"CONTAINR",{|| Lo100Manut(ALT_DET) },STR0002}) //"Manut. Lotes"

   // Carrrega dados do embarque
   MsAguarde({|| MsProcTxt(STR0003), lOK:= Lo100Work()},STR0004)   //"Gravando arquivo temporário..."###"Embarque"
   IF !lOK
      Break
   Endif

   For nInc := 1 TO (cAlias)->(FCount())
      M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
   Next nInc

   IF !EEC->(RecLock("EEC",.F.))
      Break
   Endif   

   WorkIP->(dbSetFilter({|| WP_FLAG == cMarca },"WP_FLAG =='"+cMarca+"'"))
   WorkIP->(dbGoTop())    

   DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      aPosEnc:= PosDlgUp(oDlg)

      EnChoice( cAlias, nReg, nOpc, , , ,aHDEnchoice,aPosEnc)
        
      aPos := PosDlgDown(oDlg)
         
      oMsSelect := MsSelect():New("WorkIP",,,aCampoPED,@lInverte,@cMarca,aPos)
      oMsSelect:bAval := {|| Lo100Manut(VIS_DET) }  
                 
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)

   WorkIP->(dbClearFilter())
      
   If nOpcA == 0
   
      If nOpc == INCLUIR
         While __lSX8
           RollBackSX8()
         Enddo
      Endif
   
   Elseif nOpcA == 1 .Or. nOpcA == 2 
   
      Begin Transaction

          Processa({||lGravaOk:=Lo100Grava()})                          

      End Transaction
   
   Endif
                  
End Sequence

E_RESET_AREA
      
RestOrd(aOrd) // Restaura ordem dos alias ...

Select(nSelect)

Return lRet
     


/*
Funcao      : Lo100Work()
Parametros  : 
Retorno     : .T.
Objetivos   : Gravacao de Itens do Embarque na Work 
Autor       : Osman Medeiros Jr.
Data/Hora   : 30/01/2003 08:17
Revisao     : 
Obs.        :
*/
*------------------
Static Function Lo100Work()
*------------------
Local lRet := .F.
           
Begin Sequence

   WorkIP->(avzap())

   EXI->(dbSetOrder(1))
   EE8->(dbSetOrder(1))
   EE9->(dbSetOrder(2))
   EE9->(dbSeek(xFilial("EE9")+EEC->EEC_PREEMB))
      
   While !EE9->(Eof()) .And. ;
         EE9->EE9_FILIAL == xFilial("EE9") .And.;
         EE9->EE9_PREEMB == EEC->EEC_PREEMB
         
      WorkIP->(dbAppend())
         
      AvReplace("EE9","WorkIP")
         
      WorkIP->EE9_VM_DES := MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES")[AV_TAMANHO])                    

      WorkIP->WP_FLAG := cMARCA
      WorkIP->WP_RECNO  :=EE9->(RECNO())
            
      If EE8->(dbSeek(xFilial("EE8")+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
         WorkIP->WP_SLDATU :=EE8->EE8_SLDATU
      Endif

      EXI->(dbSeek(xFilial("EXI")+EE9->(EE9_PREEMB+EE9_SEQEMB+EE9_PEDIDO)))
      While !EXI->(Eof()) .And.;
            EXI->EXI_FILIAL == xFilial("EXI") .And.;
            EXI->(EXI_PREEMB+EXI_SEQEMB+EXI_PEDIDO) == EE9->(EE9_PREEMB+EE9_SEQEMB+EE9_PEDIDO)
   
         Work_Lote->(dbAppend())
         AvReplace("EXI","Work_Lote")
         Work_Lote->WK_RECNO := EXI->(RecNo())
                                                   
         EXI->(dbSkip())
          
      EndDo                                                           

      EE9->(dbSkip())
      lRet := .T. 

   Enddo
                 
End Sequence

Return lRet

/*
Funcao      : Lo100Grava()
Parametros  : 
Retorno     : .T.
Objetivos   : Gravacao final
Autor       : Osman Medeiros Jr.
Data/Hora   : 30/01/2003 11:53
Revisao     : 
Obs.        :
*/
*------------------
Static Function Lo100Grava()
*------------------
Local lRet := .F.         
Local i

Work_Lote->(dbGoTop())
Do While !Work_Lote->(Eof())

   If Empty(Work_Lote->WK_RECNO)
      EXI->(RecLock("EXI",.T.))
   Else
      EXI->(dbGoTo(Work_Lote->WK_RECNO))
      EXI->(RecLock("EXI",.F.))         
   EndIf

   AvReplace("Work_Lote","EXI")               
   EXI->EXI_FILIAL := xFilial("EXI")
   EXI->(MsUnlock())    
                 
   Work_Lote->(dbSkip())
   lRet := .T.
EndDo

For i:=1 to len(aDelEXI1)  
   EXI->(dbGoTo(aDelEXI1[i]))
   if !EXI->(eof()) //FJH 05/08/05 ==> evitar a exclusão de registros inexistentes (EOF)
      EXI->(RecLock("EXI",.F.))
      EXI->(dbDelete())
      EXI->(MsUnlock())
      lRet := .T.
   endif
Next i 

Return lRet

/*
Funcao      : Lo100Manut()
Parametros  : 
Retorno     : .T.
Objetivos   : Browse de Lotes.
Autor       : Osman Medeiros Jr.
Data/Hora   : 30/01/2003 09:54
Revisao     : 
Obs.        :
*/
*------------------
Static Function Lo100Manut(nOpc)
*------------------
Local oDlg,nInc,cNewtit,aPos,aPosEnc
Local nSelect := Select()    
Local bOk := {|| nOpc1 := 1, oDlg:End() }
Local bCancel := {|| nOpc1 := 0,oDlg:End() },nOpc1:=0
Local aCampoEXI:= ArrayBrowse("EXI","Wrk_Lote2")
Private aTela[0][0],aGets[0]
Private aButtons := {}
Private nSaldoLOTE := WorkIP->EE9_SLDINI

Begin Sequence

   If nOpc == VIS_DET
      aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| Lo100Det(VIS_DET,oMsSelect) },STR0005}) //"Visualizar"
   Else
      aAdd(aButtons,{"BMPINCLUIR" /*STR0020*/,{|| Lo100Det(INC_DET,oMsSelect) },STR0006}) //"EDIT"###"Incluir"
      aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/    ,{|| Lo100Det(ALT_DET,oMsSelect) },STR0007}) //"Alterar"
      aAdd(aButtons,{"EXCLUIR",{|| Lo100Det(EXC_DET,oMsSelect) },STR0008}) //"Excluir"
   EndIF   

   Work_Lote->(dbSetFilter({|| EXI_SEQEMB == WorkIP->EE9_SEQEMB },"EXI_SEQEMB =='"+WorkIP->EE9_SEQEMB+"'"))

   Work_Lote->(dbGoTop())
   Wrk_Lote2->(avzap())
   Do While !Work_Lote->(Eof())

      nSaldoLOTE -= Work_Lote->EXI_QTDE          

      Wrk_Lote2->(dbAppend())
      AvReplace("Work_Lote","Wrk_Lote2")
      Wrk_Lote2->WK_RECNO := Work_Lote->(RecNo())
      
      Work_Lote->(dbSkip())

   EndDo

   aDelEXI2 := {}
   Wrk_Lote2->(dbGoTop())
      
   For nInc := 1 TO WorkIP->(FCount())
      M->&(WorkIP->(FIELDNAME(nInc))) := WorkIP->(FIELDGET(nInc))
   Next nInc
       
   cNewTit:=(STR0009+M->EE9_PREEMB)  //"Manutenção de Lotes para o Embarque "
       
   DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL
          
      aPosEnc := PosDlgUp(oDlg)
      aPosEnc[3] += 30                   	
                    
      EnChoice( "EE9", ,3, , , ,aItemEnchoice,aPosEnc,{},3)          
                  
      aPos := PosDlgDown(oDlg)
      aPos[1] += 30                         
      aPos[3] -= 26

      // by CRF 27/10/2010 12:29
      aCampoEXI := AddCpoUser(aCampoEXI,"EXI","5","Wrk_Lote2")


      oMsSelect := MsSelect():New("Wrk_Lote2",,,aCampoEXI,@lInverte,@cMarca,aPos)
      oMsSelect:bAval := {|| Lo100Det(VIS_DET,oMsSelect) }  

      aPos[1] := aPos[3]
      aPos[3] := aPos[1]+28

      Lo100TelaSaldo(aPos,oDlg)
       
      // Puxar memo do work ...
      M->EE9_VM_DES := WorkIP->EE9_VM_DES
                                             
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)     
        
   If nOpc1 == 1 .And. nOpc <> VIS_DET // Alteracoes nao confirmadas...

      Wrk_Lote2->(dbGoTop())

      Do While !Wrk_Lote2->(Eof())
         
         nRecOld := 0
         If Empty(Wrk_Lote2->WK_RECNO)
           Work_Lote->(RecLock("Work_Lote",.T.))
         Else
           Work_Lote->(dbGoTo(Wrk_Lote2->WK_RECNO))
           nRecOld := Work_Lote->WK_RECNO
           Work_Lote->(RecLock("Work_Lote",.F.))         
         EndIf

         AvReplace("Wrk_Lote2","Work_Lote")               
         Work_Lote->WK_RECNO := nRecOld
         Work_Lote->(MsUnlock())    
                         
         Wrk_Lote2->(dbSkip())

      EndDo 
      
      For nInc := 1 To Len(aDelEXI2)
         Work_Lote->(dbGoTo(aDelEXI2[nInc]))
		 AADD( aDelEXI1, Work_Lote->WK_RECNO )  //Alexsander, Linha alterada.
//       Aadd(aDelEXI1,Work_Lote->(RecNo()))
         If !Work_Lote->(eof()) //FJH  05/08/2005 ==> 	Linha adicionada pq qdo o lote é incluso e 
            Work_Lote->(dbDelete()) 				//	apagado na mesma sessão ele é adicionado no
         endif                                      //	aDelEXI1 mas não está na work
      Next nInc
   
   EndIf 

   Work_Lote->(dbClearFilter())
   
End Sequence

Select(nSelect)

Return .T.                                                       

/*                                                               
Funcao      : Lo100Det()
Parametros  : 
Retorno     : .T.
Objetivos   : Inclusao / Alteracao / Exclusao de Lotes
Autor       : Osman Medeiros Jr.
Data/Hora   : 30/01/2003 09:54
Revisao     : 
Obs.        :
*/
*------------------
Static Function Lo100Det(nOpc,oMsSelect)
*------------------                                                                       
Local nAreaOld := Select()
Local oDlg, cNewTit, i
Local nOpcA := 0

// by CAF aparecer todos os campos do SX3 Local aEnchoice:={"EXI_QTDE","EXI_LOTE"}

Private aTela[0][0], aGets[0]

Begin Sequence     

   IF nOpc == INC_DET
   
      For i := 1 TO Wrk_Lote2->(FCount())
         IF Wrk_Lote2->(FieldName(i)) = "DBDELETE" .Or.;
             "RECNO" $ Wrk_Lote2->(FieldName(i))
            Loop
         Endif
         M->&(Wrk_Lote2->(FieldName(i))) := CriaVar(Wrk_Lote2->(FieldName(i)))
      Next i
   
   Else           
   
      IF Wrk_Lote2->(Eof() .And. Bof())
         MsgInfo(STR0010,STR0011) //"Não possui lotes selecionados!"###"Aviso"
         Break
      Endif
      
      For i := 1 TO Wrk_Lote2->(FCount())
         M->&(Wrk_Lote2->(FieldName(i))) := Wrk_Lote2->(FieldGet(i))
      Next i

   Endif
             
   cNewTit := STR0012 + AllTrim(WorkIP->EE9_SEQEMB)  //"Lote do Item "
   
   IF nOpc == VIS_DET
      cNewTit += STR0013 //" - Visualizar"
   Elseif nOpc == INC_DET
      cNewTit += STR0014 //" - Incluir"
   Elseif nOpc == ALT_DET
      cNewTit += STR0015 //" - Alterar"
   Else
      cNewTit += STR0016 //" - Excluir"
   Endif
      
   DEFINE MSDIALOG oDlg TITLE cNewTit FROM 9,0 TO 25,80 OF oMainWnd // LRS 25/08/2014 - Aumentado o tamanho da MsDialog

     EnChoice("EXI", , 3, , , , /*aEnchoice*/, PosDlg(oDlg),IF(Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},),3)
     
     bOk     := {|| If(Lo100Valida(nOpc),(nOpcA:=1,oDlg:End()),) }
     bCancel := {|| nOpcA:=0,oDlg:End() }
          
   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)
                                  
   IF nOpcA == 1

      If nOpc == INC_DET
         Wrk_Lote2->(dbAppend())
         nSaldoLOTE -= Wrk_Lote2->EXI_QTDE
      Endif

      If ! Str(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1)         
         If nOpc == ALT_DET
            nSaldoLOTE += Wrk_Lote2->EXI_QTDE
         Endif    
         AvReplace("M","Wrk_Lote2")
         Wrk_Lote2->EXI_PREEMB := WorkIP->EE9_PREEMB
         Wrk_Lote2->EXI_SEQEMB := WorkIP->EE9_SEQEMB
         Wrk_Lote2->EXI_PEDIDO := WorkIP->EE9_PEDIDO                                    
         nSaldoLOTE -= Wrk_Lote2->EXI_QTDE
      Endif    
      
      If nOpc == EXC_DET                    
         nSaldoLOTE += Wrk_Lote2->EXI_QTDE
         Aadd(aDelEXI2,Wrk_Lote2->WK_RECNO)
         Wrk_Lote2->(dbDelete())               
      EndIf

      Wrk_Lote2->(dbGoTop())               

      oMsSelect:oBrowse:Refresh()

   Endif
   
End Sequence

Select(nAreaOld)

Return


/*
Funcao      : Lo100TelaSaldo()
Parametros  : 
Retorno     : .T.
Objetivos   : Exibe o saldo no rodape do Itens.
Autor       : Osman Medeiros Jr.
Data/Hora   : 30/01/2003 14:57
Revisao     : 
Obs.        :
*/
*------------------
Static Function Lo100TelaSaldo(aPos,oDlg)
*------------------                                                                       
Local nL1,nTamCol,C1,nC2,nC3,nC4

Begin Sequence

   nL1:= aPos[1]+6 

   nTamCol := (aPos[4]-aPos[2])/4
   
   nC1:=aPos[2]+21 
   nC2:=nC1+nTamCol
   
   @ aPos[1],aPos[2] TO aPos[3],aPos[4] PIXEL

   @ nL1,nC1 SAY STR0019 PIXEL SIZE 50,7 // "Saldo"
 
   @ nL1,nC2 MSGET nSaldoLote PICTURE AVSX3("EE9_SLDINI",6) WHEN .F. SIZE 55,6 RIGHT PIXEL

End Sequence

Return

/*
Funcao      : Lo100Valida()
Parametros  : 
Retorno     : .T.
Objetivos   : Validacao da Tela de Lotes.
Autor       : Osman Medeiros Jr.
Data/Hora   : 30/01/2003 14:57
Revisao     : 
Obs.        :
*/
*------------------
Static Function Lo100Valida(nOpc)
*------------------                                                                       
Local lRet := .t.
Local nSaldoRec := 0 
Begin Sequence

   If ! Str(nOpc,1) $ Str(INC_DET,1)+"/"+Str(ALT_DET,1)         
      Break
   EndIf   
   
   If !Obrigatorio(aGets,aTela)
      lRet := .F.
      Break
   Endif   

   If nOpc = ALT_DET
      nSaldoRec := Wrk_Lote2->EXI_QTDE
   EndIf   
   
   If (nSaldoLOTE + nSaldoRec - M->EXI_QTDE) < 0 
      MsgInfo(STR0017,STR0018) //"Valor informado maior que o saldo disponível!"###"Informação"
      lRet := .F.
      Break
   EndIf
      
End Sequence   
   
Return lRet

/*
Funcao      : AvUsado
Parametros  : 
Retorno     : Se o campo existe no SX3 e se o mesmo está em uso retorna TRUE
Objetivos   : Verificar se o campo esta em uso e se nao estiver adicionar no aSemSX3
Autor       : Cristiano A. Ferreira
Data/Hora   : 12/02/2003 14:30
Revisao     : 
Obs.        :
*/
Function AvUsado(cCpo,aSemSX3)

Local lRet := .f.
Local aOrd := SaveOrd("SX3")

Begin Sequence
   SX3->(dbSetOrder(2))
   IF SX3->(dbSeek(cCpo)) .And. X3Uso(SX3->X3_USADO)
      lRet := .t.
   Else
      IF ValType(aSemSX3) == "A"
         aAdd(aSemSX3,{cCpo,AVSX3(cCpo,AV_TIPO),AVSX3(cCpo,AV_TAMANHO),AVSX3(cCpo,AV_DECIMAL)})
      Endif
   Endif
End Sequence

RestOrd(aOrd)

Return lRet