#include "PROTHEUS.CH"
#include "EEC.CH" 


/*
Funcao    : EYJCOMP()
Parametros: cAlias,nReg,nOpc
Objetivos : Manutenção dos dados Complementares de Produtos (SB1)
Autor     : Allan Oliveira Monteiro	
Data/Hora : 06/05/2011
*/

*----------------*
Function EYJCOMP(cAlias,nReg,nOpc)
*----------------*
Local lRet := .t., lSeek := .F.
Local aPos := {} , aCpoShow := {} 
Local nOpcao := 0 , i, nInc
Local bOk     := {|| nOpcao := 1 ,  If(!lExecAuto, oDlg:End(),)},; //FSM - 05/01/12 - ExecAuto
      bCancel := {|| If(!lExecAuto, oDlg:End(),)} //FSM - 05/01/12 - ExecAuto
Local oDlg , oEnch
Local nFolderSB5
Local aOrd := SaveOrd({"SX3","SXA","SB5"})
Local lSeekSB5
Local aCampo := {{'EYJ',"EYJ_SB5"} }

Private cTitulo:= AvTitCad("EYJ") 
Private aTela[0][0],aGets[0]
Private aCamposSB5 := {}
                                                            
//FSM - 05/01/12 - ExecAuto          
lExecAuto := Type("lExecAuto") == "L" .And. lExecAuto


Begin Sequence
   
   If EYJ->(FieldPos("EYJ_ADE" )) > 0 .And. EYJ->(FieldPos("EYJ_EMBESP")) > 0 .And.; //LRS - 17/02/2014 - Colocado novos campos na Aba Outros
    EYJ->(FieldPos("EYJ_LEADTI")) > 0 .AND. EYJ->(FieldPos("EYJ_PRODUC")) > 0 .And.;
    EYJ->(FieldPos("EYJ_ESTSIM")) > 0 .AND. EYJ->(FieldPos("EYJ_DESTAQ")) > 0
    
     AADD(aCpoShow,"EYJ_ADE"   )
     AADD(aCpoShow,"EYJ_EMBESP")
     AADD(aCpoShow,"EYJ_LEADTI")
     AADD(aCpoShow,"EYJ_PRODUC")
     AADD(aCpoShow,"EYJ_ESTSIM")
     AADD(aCpoShow,"EYJ_DESTAQ")
   EndIf
   
   //RRC - 21/09/2012 - Adiciona Campo Virtual utilizado pela aba "Complementos de Produtos"       //NCF - 09/01/2012 - Adicionado tratamento para verificar AvFlags do Siscoserv Cadastros
   If (AvFlags("CONTROLE_SERVICOS_AQUISICAO") .Or. AvFlags ("CONTROLE_SERVICOS_VENDA") .Or. AvFlags("CONTROLE_CADASTROS_SISCOSERV")) .And. AvExisteCampo(aCampo) 
      AADD(aCpoShow,"EYJ_SB5")
   EndIf
   
   //FSM - 05/01/12 - ExecAuto 
   If EYJ->(FieldPos("EYJ_CCERP" )) > 0
      AADD(aCpoShow,"EYJ_CCERP"   ) 
   EndIf 

   If EYJ->(FieldPos("EYJ_DESEXP" )) > 0
      AADD(aCpoShow,"EYJ_DESEXP"   ) 
   EndIf 

//   If EYJ->(FieldPos("EYJ_NVE" )) > 0  // GFP - 28/10/2016
//      AADD(aCpoShow,"EYJ_NVE"   ) 
//   EndIf 

   //RMD - 14/10/16 - Campo para informar ID da declaração de produto na FIESP (ECOOL)
   If EYJ->(FieldPos("EYJ_CODFIE" )) > 0
      AADD(aCpoShow,"EYJ_CODFIE"   ) 
   EndIf 

   EYJ->(DbSetOrder(1))
   lSeek := EYJ->(DbSeek(xFilial("EYJ") + SB1->B1_COD ))

   For i := 1 to EYJ->(FCount())
      If lSeek 
	      M->&(EYJ->(FieldName(i))):= EYJ->(FieldGet(i))  //Alteração   
	  else
	     M->&(EYJ->(FieldName(i))):= CriaVar(EYJ->(FieldName(i))) //Inclusão
	  Endif	
   Next i  
   
   //RRC - 21/09/2012 - Inclui campos da tabela de Dados Adicionais de Produto
   SB5->(DbSetOrder(1))
   lSeekSB5 := SB5->(DbSeek(xFilial("SB5") + SB1->B1_COD ))                            //NCF - 09/01/2012 - Adicionado tratamento para verificar AvFlags do Siscoserv Cadastros
   If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .Or. AvFlags ("CONTROLE_SERVICOS_VENDA") .Or. AvFlags("CONTROLE_CADASTROS_SISCOSERV")
      If lSeekSB5
         RegToMemory("SB5",.T.) // Para criar os virtuais
         For nInc := 1 TO SB5->(FCount())
            M->&(SB5->(FieldName(nInc))) := SB5->(FieldGet(nInc))
         Next
      Else
         RegToMemory("SB5",.T.) // Para criar os virtuais
         M->B5_COD := SB1->B1_COD
      EndIf
   EndIf
   
   If EECFlags("INTTRA")
      If lSeek 
           M->EYJ_COMPER := MSMM(EYJ->EYJ_CCOMPE,AVSX3("EYJ_COMPER",AV_TAMANHO),,,LERMEMO)
      Else
           M->EYJ_COMPER := "" 
      EndIf 
   EndIf
   
   //FSM - 08/12/11 - ExecAuto          
   If !lExecAuto
   
       Define MsDialog oDlg Title cTitulo From DLG_LIN_INI,DLG_COL_INI To DLG_LIN_FIM,DLG_COL_FIM Of oMainWnd Pixel
          aPos:= PosDlg(oDlg)
          oEnch := MsMGet():New("EYJ",nReg,nOpc,nil,nil,nil,aCpoShow,aPos,)
          nFolderSB5 := If(EasyGParam("MV_ESS0022",,.F.) .OR. EasyGParam("MV_ESS0014",,.F.),Val(RetAsc(Right(AllTrim(aGets[aScan(aGets, {|x| IncSpace("EYJ_SB5", 10, .F.) $ x })]),1),1,.F.)),1)  // GFP - 30/01/2014
          //RRC - 21/09/2012 - Tratamento para incluir campos de Complementos de Produtos        //NCF - 09/01/2012 - Adicionado tratamento para verificar AvFlags do Siscoserv Cadastros
          If (AvFlags("CONTROLE_SERVICOS_AQUISICAO") .Or. AvFlags ("CONTROLE_SERVICOS_VENDA").Or. AvFlags("CONTROLE_CADASTROS_SISCOSERV")) .And. AvExisteCampo(aCampo)  .And. ValType(nFolderSB5) == "N" .And. nFolderSB5 > 0
             SX3->(DbSetOrder(2))
             SXA->(DbSetOrder(1))
             oFolderSB5 := oEnch:oBox:aDialogs[nFolderSB5]
             aGetsSB5 := aClone(aGets)
             aTelaSB5 := aClone(aTela)
             aGets := {}
             aTela := {}
                
             oPanel1:=TPanel():New(0,0, "", oFolderSB5,, .T., ,,,0,0,,.T.)
             oPanel1:Align:= CONTROL_ALIGN_ALLCLIENT
                
             aCamposSB5 := CmpSB5()
             oEncSB5 := MsmGet():New("SB5",nReg,nOpc,,,,aCamposSB5,;
                    {1,1,(oFolderSB5:nClientHeight-6)/2,(oFolderSB5:nClientWidth-4)/2},,,,,,;
                    oPanel1)
             aGets := aClone(aGetsSB5)
             aTela := aClone(aTelaSB5)
             oEncSB5:oBox:Align:=CONTROL_ALIGN_ALLCLIENT
          EndIf
       Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel)
   
   Else
   	   
       If lRet := EnchAuto(cAlias, aAutoComp, {|| Obrigatorio(aGets, aTela) }, nOpc, aCpoShow)
          Eval(bOk)
       Else
          Eval(bCancel)
       EndIf
   
   EndIf


   If nOpcao == 1
      EYJ->(DbSetOrder(1))
      If EYJ->(DbSeek(xFilial("EYJ")+SB1->B1_COD))   
         If EYJ->(RecLock("EYJ",.F.))
            AvReplace("M","EYJ")
         EndIf 
         If EECFlags("INTTRA")
		    MSMM(M->EYJ_CCOMPE,,,,EXCMEMO)
		 Endif
           
      Else
   
         If EYJ->(RecLock("EYJ",.T.))
            AvReplace("M","EYJ")
            EYJ->EYJ_FILIAL := xFilial("EYJ")
            EYJ->EYJ_COD    := SB1->B1_COD 
         EndIf
   
      EndIf
      
	  If EECFlags("INTTRA")
         MSMM(,AVSX3("EYJ_COMPER" ,AV_TAMANHO),,M->EYJ_COMPER ,INCMEMO,,,"EYJ","EYJ_CCOMPE")
	  EndIf

      EYJ->(MsUnlock())
                                                                                              //NCF - 09/01/2012 - Adicionado tratamento para verificar AvFlags do Siscoserv Cadastros
      If AvFlags("CONTROLE_SERVICOS_AQUISICAO") .Or. AvFlags ("CONTROLE_SERVICOS_VENDA") .Or. AvFlags("CONTROLE_CADASTROS_SISCOSERV")
         //RRC - 24/09/2012 - Salva registros na tabela SB5 (Dados Adicionais de Produto)
         SB5->(DbSetOrder(1))
         If SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))
            If SB5->(RecLock("SB5",.F.))
               AvReplace("M","SB5") 
               SB5->(MsUnLock())                
            EndIf          
         Else
            If SB5->(RecLock("SB5",.T.))
               AvReplace("M","SB5")
               SB5->B5_FILIAL := xFilial("SB5")
               SB5->(MsUnLock()) 
            EndIf             
         EndIf
      EndIf
   EndIf
      
End Sequence 
RestOrd(aOrd,.T.)
Return

/*
Programa   : CmpSB5()
Objetivo   : Adicionar os campos a serem exibidos para a "Dados Complementares do Produto"
Retorno    : Nil
Autores    : Rafael Ramos Capuano - RRC 
Data/Hora  : 21/09/2012 15:15
Revisão
*/

Static Function CmpSB5()
Local aCamposSB5 :={}
Local aOrd       := SaveOrd({"SX3"})
DbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek("SB5"))

Do While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "SB5"
   If !SX3->X3_CAMPO $ "_FILIAL" .And. X3Uso(SX3->X3_USADO) 
      Aadd(aCamposSB5,SX3->X3_CAMPO)
   EndIf 
   SX3->(dbSkip())  
EndDo

RestOrd(aOrd,.T.)
Return aClone(aCamposSB5) 