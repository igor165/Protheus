#INCLUDE "hspahac6.ch"
#include "protheus.CH"
#include "colors.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC6  �Autor  �Andr� Cruz          � Data �  27/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


Function HSPAHAC6()
 Local aCores := {{"EMPTY(GN9->GN9_DATVLD) .Or.  (GN9->GN9_DATVLD - dDataBase) >= 30"      , "BR_VERDE"   }, ;
                  {"GN9->GN9_DATVLD >= dDataBase .And. (GN9->GN9_DATVLD - dDataBase) <  30", "BR_AMARELO" }, ;
                  {"!EMPTY(GN9->GN9_DATVLD) .And.  GN9->GN9_DATVLD < dDataBase"            , "BR_VERMELHO"}}

 Private cCadastro := STR0001 //"Credenciamento de M�dicos por Taxa/Di�ria"
 
 Private aRotina := {{ OemtoAnsi(STR0002), "axPesqui" , 0, 1}, ;  //"Pesquisar"
                     { OemToAnsi(STR0003), "HS_MntAC6", 0, 2}, ;  //"Visualizar"
                     { OemToAnsi(STR0004), "HS_MntAC6", 0, 3}, ;  //"Incluir"
                     { OemToAnsi(STR0005), "HS_MntAC6", 0, 4}, ;  //"Alterar"
                     { OemToAnsi(STR0006), "HS_MntAC6", 0, 5}, ;  //"Excluir"
                     { OemToAnsi(STR0027), "HS_RefGNB()", 0, 4}, ;  // "Refaz Regras"
                     { OemtoAnsi(STR0007), "HS_LegAC6", 0, 1} } //"Legenda"

Private lGFR := HS_LocTab("GFR", .F.) 

Private cGcmcodcon := "" 

 mBrowse(06, 01, 22, 75, "GN9",,,,,, aCores)
Return(Nil)

Function HS_MntAC6(cAliasAC6, nRegAC6, nOpcAC6)
 Local nOpcDlg := 0, nGDOpc := IIf(StrZero(aRotina[nOpcAC6, 4], 2) $ "03/04", GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local aHGNA := {}, aCGNA := {}, oEnGN9
 
 Private aTela := {}, aGets := {}, oGDGNA, nUGNA := 0
 
 Private nGNAIteVig := 0
 
 DbSelectArea("GNB")
 DbSelectArea("GNA")
 DbSelectArea("GN9")

 RegToMemory("GN9", IIf(aRotina[nOpcAC6, 4] == 3, .T., .F.))
   
 HS_BDados("GNA", @aHGNA, @aCGNA, @nUGNA, 1, M->GN9_CODSEQ, IIf(aRotina[nOpcAC6, 4] == 3, Nil, "GNA->GNA_CODSEQ == '" + M->GN9_CODSEQ + "'"))
 
 nGNAIteVig := aScan(aHGNA, {|aVet| AllTrim(aVet[2]) == "GNA_ITEVIG"})
        
 If aRotina[nOpcAC6, 4] == 3
  aCGNA[1, nGNAIteVig] := Soma1(aCGNA[1, nGNAIteVig], Len(aCGNA[1, nGNAIteVig]))
 EndIf 
  
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 050, .T., .T. } )	
 AAdd( aObjects, { 100, 050, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel
  oEnGN9 := MsMGet():New("GN9", nRegAC6, nOpcAC6,,,,, aPObjs[1],, 2)                          
  oEnGN9:oBox:align := CONTROL_ALIGN_TOP
   
  oGDGNA := MsNewGetDados():New(aPObjs[2, 1]+05, aPObjs[2, 2], aPObjs[2, 3]+10, aPObjs[2, 4], nGDOpc,,, "+GNA_ITEVIG",,, 99999,,,,, aHGNA, aCGNA)
  oGDGNA:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(FS_VldCrd(nOpcAC6), oDlg:End(), nOpcDlg := 0)}, ;
                                                  {|| nOpcDlg := 0, oDlg:End()})
 If nOpcDlg == 0
  While __lSx8
   RollBackSxe()
  End
 Else     
  Begin Transaction
   FS_GrvAC6(nOpcAC6, aHGNA, oGDGNA, nUGNA)
  End Transaction 
  
  While __lSx8
   ConfirmSx8()
  End
 EndIf
Return(Nil)                                                                               
                                                                        
Static Function FS_VldCrd(nOpcAC6)
 Local lRet := .T.
 
 If StrZero(aRotina[nOpcAC6, 4], 2) $ "03/04"
  lRet := Obrigatorio(aGets, aTela) .And. oGDGNA:TudoOk() .And. FS_VldRAC6(nOpcAC6)
 EndIf
 
Return(lRet) 

Static Function FS_GrvAC6(nOpcAC6, aHGNA, oGDGNA, nUGNA)
 Local nForItens	:= 0, lFoundGN9 := .F., lFoundGNA := .F.

 If aRotina[nOpcAC6, 4] <> 2
  Begin Transaction
   DbSelectArea("GN9")
   DbSetOrder(6)

   If aRotina[nOpcAC6, 4] == 3 // Inclus�o
    M->GN9_CODSEQ := HS_VSxeNum("GN9", "M->GN9_CODSEQ", 6)
   Else
    lFoundGN9 := DbSeek(xFilial("GN9") + M->GN9_CODSEQ)
   EndIf
   
   If aRotina[nOpcAC6, 4] <> 5
    RecLock("GN9", !lFoundGN9)
     HS_GRVCPO("GN9")
     GN9->GN9_FILIAL := xFilial("GN9")
    MsUnLock()
	   
    If ( aRotina[nOpcAC6, 4] == 3 ) // Inclus�o
     FS_AtuGNB("I")
    EndIf

    For nForItens := 1 To Len(oGDGNA:aCols)
     DbSelectArea("GNA")
     DbSetOrder(1)

     lFoundGNA := DbSeek(xFilial("GNA") + M->GN9_CODSEQ + oGDGNA:aCols[nForItens, nGNAIteVig])
		  	
     If !oGDGNA:aCols[nForItens, nUGNA + 1]
      RecLock("GNA", !lFoundGNA)
       HS_GRVCPO("GNA", oGDGNA:aCols, aHGNA, nForItens)
       GNA->GNA_FILIAL := xFilial("GNA")
       GNA->GNA_CODSEQ := M->GN9_CODSEQ
      MsUnlock()
   	 Else
   	  If lFoundGNA
  	   RecLock("GNA", .F.)
        DbDelete()
       MsUnlock()
       WriteSx2("GNA")
      Endif
     Endif
    Next
   Else 
    If lFoundGN9
     RecLock("GN9", .F.)
      DbDelete()
     MsUnLock() 
     WriteSx2("GN9")
	    
     FS_AtuGNB("E")

     For nForItens := 1 To Len(oGDGNA:aCols)
      DbSelectArea("GNA")
      DbSetOrder(1)
      If DbSeek(xFilial("GNA") + M->GN9_CODSEQ + oGDGNA:aCols[nForItens, nGNAIteVig])
       RecLock("GNA", .F.)
        DbDelete()
       MsUnlock()
       WriteSx2("GNA")
      Endif
     Next
    EndIf 
   EndIf 
  End Transaction
 EndIf
 
 DbSelectArea("GN9")
Return(Nil)            

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC6  � Autor � Gilson da Silva    � Data �  11/01/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Valida a digitacao dos campos do GN9.                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FS_VldRAC6(nOpcAC6)
 Local lRet := .T., cAliasOld := Alias()
 
 If aRotina[nOpcAC6, 4] == 3
  DbSelectArea("GN9")   //Vai verificar se ja existe credenciamento cadastrado
  DbSetOrder(5)
  If DbSeek(xFilial("GN9") + M->GN9_TIPCRE + M->GN9_CODPRE + M->GN9_CODPRO + M->GN9_CODGPA + M->GN9_CODLOC + M->GN9_CODCRM + M->GN9_CODPLA + M->GN9_CODCON + M->GN9_CARATE)
   HS_MsgInf(STR0008 + GN9->GN9_CODSEQ + STR0009, STR0010, cCadastro) //"Credenciamento ("###") j� cadastrado com estes atributos."###"Aten��o"
   lRet := .F.
  Endif 
 Endif 
 
 DbSelectArea(cAliasOld)
Return(lRet) 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_AtuGNB � Autor � Cibele PEria       � Data �  26/01/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Trata a gravacao do arquivo de regras de credenciamento    ���
���          � utilizadas                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Static Function FS_AtuGNB(cOpcao,lRefaz)
 Local lAchou     := .T., cAliasOld := Alias()
 Local nForCpo    := 0
 Local aVetGNB    := {}                                                                                                          
 Default lRefaz   := .F.
 
 aVetGNB := HS_ChvCrd({"GN9","GNB"}, .T.)
 
 DbSelectArea("GNB")
 DbSetOrder(2)  // GNB_FILIAL+GNB_TIPCRE+GNB_CODPRE+GNB_CODGPA+GNB_CODPRO+GNB_CODLOC+GNB_CODCRM+GNB_CODPLA+GNB_CODCON
 
 lAchou := DbSeek(xFilial("GNB") + M->GN9_TIPCRE + M->GN9_CODPRE + aVetGNB[1])
 
 If cOpcao == "I"
  RecLock("GNB", !lAchou)
   If lRefaz
       If Empty(xFilial("GNB"))
           GNB->GNB_FILIAL := xFilial("GNB")
       Else
           GNB->GNB_FILIAL := M->GN9_FILIAL
       EndIf
   Else
       GNB->GNB_FILIAL := xFilial("GNB")
   Endif    
   
   If !lAchou
    GNB->GNB_TIPCRE := M->GN9_TIPCRE
    GNB->GNB_CODPRE := M->GN9_CODPRE
    GNB->GNB_CODCRM := M->GN9_CODCRM
    GNB->GNB_PRIORI := "9999"
    
    For nForCpo := 1 To Len(aVetGNB[2])
    	If GNB->(FieldPos(aVetGNB[2][nForCpo][1]))>0
   
		   	  &("GNB->" + aVetGNB[2][nForCpo][1]) := aVetGNB[2][nForCpo][2]
   
        Endif
    Next
   Endif 
   
   GNB->GNB_QTDREG := IIF(lAchou, GNB->GNB_QTDREG+1, 1)
  MsUnlock()
 Else
  If GNB->GNB_QTDREG == 1
   RecLock("GNB", .F., .T.)
    DbDelete()
   MsUnlock()
  Else
   RecLock("GNB", .F.)
    GNB->GNB_QTDREG := GNB->GNB_QTDREG - 1
   MsUnlock()   
  Endif
 Endif
  
 DbSelectArea(cAliasOld)
Return()

Function HS_LegAC6()
 BrwLegenda(cCadastro, STR0007, { {"BR_VERDE",    STR0011}, ;  //"Legenda"###"Mais de 30 dias"
                                  {"BR_AMARELO",  STR0012}, ;  //"Menos de 30 dias"
                                  {"BR_VERMELHO", STR0013} })  //"Validade vencida"
Return(.T.)                                                                          

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldGN9 � Autor � MARIO ARIZONO      � Data �  18/10/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Valida campos da tabela GN9.                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HS_VldGN9()
      
Local lRet := .T. 

 If ReadVar() == "M->GN9_CODCON"
  If !HS_SeekRet("GA9","M->GN9_CODCON",1,.f.,"GN9_NOMCON","GA9_NREDUZ")
   HS_MsgInf(STR0014, STR0010, cCadastro) //"C�digo do conv�nio inv�lido"###"Aten��o"
   lRet := .F.
  EndIf
  cGcmcodcon := M->GN9_CODCON 
 ElseIf Readvar() == "M->GN9_CODPLA"   .AND. !EMPTY(M->GN9_CODPLA)
   If !HS_SeekRet("GCM","M->GN9_CODCON + M->GN9_CODPLA",1,.f.,"GN9_DESPLA","GCM_DESPLA")
    HS_MsgInf(STR0015, STR0010, cCadastro) //"C�digo do plano inv�lido para o conv�nio solicitado"
    lRet := .F.
   EndIf
 ElseIf ReadVar() == "M->GN9_CODPRE" .AND. !EMPTY(M->GN9_CODPRE)
  If !HS_SeekRet("GAZ","M->GN9_CODPRE",1,.f.,"GN9_NOMPRE","GAZ_FANPRE")
   HS_MsgInf(STR0016, STR0010, cCadastro) //"C�digo do prestador inv�lido"
   lRet := .F.
  EndIf   
 ElseIf Readvar() == "M->GN9_CODCRM" .AND. !EMPTY(M->GN9_CODCRM)
  If !HS_SeekRet("SRA","M->GN9_CODCRM",11,.f.,"GN9_NOMMED","RA_NOME")
   HS_MsgInf(STR0017, STR0010, cCadastro) //"C�digo do CRM inv�lido"
   lRet := .F.
  EndIf
 ElseIf Readvar() == "M->GN9_CODLOC" .AND. !EMPTY(M->GN9_CODLOC)
  If !HS_SeekRet("GCS","M->GN9_CODLOC",1,.f.,"GN9_NOMLOC","GCS_NOMLOC")
   HS_MsgInf(STR0018, STR0010, cCadastro) //"C�digo do setor inv�lido"
   lRet := .F.
  EndIf   
 ElseIf Readvar() == "M->GN9_CODGPA" .AND. !EMPTY(M->GN9_CODGPA)
  If !HS_SeekRet("SX5","'CT'+M->GN9_CODGPA",1,.f.,"GN9_DESCPA","X5_DESCRI")
   HS_MsgInf(STR0019, STR0010, cCadastro) //"C�digo do grupo de receitas inv�lido"
   lRet := .F.
  EndIf  
 ElseIf Readvar() == "M->GN9_CODPRO" .AND. !EMPTY(M->GN9_CODPRO)
  If !HS_SeekRet("GAA","M->GN9_CODPRO",1,.f.,"GN9_DDESPE","GAA_DESC",,,.T.)
   HS_MsgInf(STR0020, STR0010, cCadastro) //"C�digo do procedimento inv�lido"
   lRet := .F.
  EndIf      
 Endif  
 
Return (lRet) 
                    
Function HS_VldAC6()
 Local lRet := .T.
 
 If ReadVar() == "M->GNA_TABPRO"
  If !Empty(M->GNA_TABPRO) .And. !(lRet := HS_SeekRet("GD2", "M->GNA_TABPRO", 1, .F., "GNA_NOMTAB", "GD2_DESCRI"))
   HS_MsgInf(STR0021, STR0010, cCadastro) //"C�digo da tabela de procedimentos n�o encontrado"
  EndIf
 EndIf
 
Return(lRet)                      


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_RefGNB �Autor  �Eduardo Alves       � Data �  21/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao que refaz as regras do credenciamento baseados na ta ���
���          �bela GN9.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_RefGNB()
 If MsgYesNo(STR0022) //"Confirma processamento das regras ?"
  Processa({|| FS_RefGNB()})
 EndIf
Return(Nil)                  

Function FS_RefGNB()
	Local aArea 	:= GetArea()

	/* Apaga GNB */
 TcSqlExec("DELETE FROM " + RetSQLName("GNB"))		
	
	DbSelectArea("GN9")
	DbSetOrder(6)
	DbGoTop()
 ProcRegua(RecCount())
 
 While !Eof()
 	RegToMemory("GN9", .F.)
 	IncProc(STR0023 + GN9->GN9_CODSEQ + "]") // //"Atualizando credenciamento ["
 	FS_AtuGNB("I",.T.)
 	DbSkip()
 EndDo
	HS_MsgInf(STR0024, STR0025, STR0026) //"Processamento conclu�do com sucesso."###"Sucesso"###"Refazendo Regras"
 RestArea(aArea)
Return
