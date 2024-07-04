#INCLUDE "hspahac2.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC2  � Autor � Andre Cruz         � Data �  01/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Oficio TISS                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHAC2()

 Local aTabela := {{"T", "GN1"}}
    	
 Private aRotina := { {OemtoAnsi(STR0001), "axPesqui", 0, 1}, ;  //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_AC2", 0, 2}, ;  //"Visualizar"
                      {OemtoAnsi(STR0003), "HS_AC2", 0, 3}, ;  //"Incluir"
                      {OemtoAnsi(STR0004), "HS_AC2", 0, 4}, ;  //"Alterar"
                      {OemtoAnsi(STR0005), "HS_AC2", 0, 5}}    //"Excluir"   
                      
                

                     

	
    	aadd(aRotina, {"Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GN1',GN1->GN1_CODCBO, 1)})", 0 ,})
		aadd(aRotina, {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('GN1',GN1->GN1_CODCBO, 0)})", 0 ,})                  

          
	
	
	DbSelectArea("GN1") 
                  
 If HS_ExisDic(aTabela) 
 	mBrowse(06, 01, 22, 75, "GN1")
 EndIf
 
 
 
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_AC2    � Autor � Andre Cruz         � Data �  28/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das fun�oes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_AC2(cAlias, nReg, nOpc)   

 Local nOpcOk := 0

 Private nOpcGN1  := aRotina[nOpc, 4]
 Private aTela 		 := {}
 Private aGets    := {}
 Private oGN1
 
 RegToMemory("GN1", (nOpcGN1 == 3)) 

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Cadastro de Of�cio TISS"

 oGN1 := MsMGet():New("GN1", nReg, nOpcGN1,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGN1:oBox:Align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcOk := 1, IIF(!FS_GrvAC2(), nOpcOk := 0, oDlg:End())}, ;
                                                   {|| nOpcOk := 0, oDlg:End()})


Return(Nil) 




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvAC2 �Autor  �Andre Cruz          � Data �  01/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvAC2()

 Local lRet := .T.
 
 If (lRet := Obrigatorio(aGets, aTela))
  Begin TransAction
	  If nOpcGN1 == 3 .Or. nOpcGN1 == 4 //Incluir e Alterar
	   RecLock("GN1", ( nOpcGN1 == 3 ) )
	    HS_GrvCpo("GN1")
	   MsUnlock()	
	  ElseIf (nOpcGN1 == 5)
	   If HS_CountTB("GBJ", "GBJ_CBOTIS = '" + GN1->GN1_CODCBO + "'") > 0
	    lRet := .F.
	    HS_MsgInf(STR0007, STR0008, STR0009)  //"O registro possui relacionamento com Cadastro de Profissional"###"Aten��o"###"Valida��o de Exclus�o"
	   Elseif HS_CountTB("GFR", "GFR_CBOTIS = '" + GN1->GN1_CODCBO + "'") > 0
	    lRet := .F.
	    HS_MsgInf(STR0014, STR0008, STR0009)  //"O registro possui relacionamento com Cadastro de Especialidades"###"Aten��o"###"Valida��o de Exclus�o"
	   Else
	    RecLock("GN1", .F.)
	     DbDelete()
	    MsUnlock()
	   EndIf
	  EndIf
	 End TransAction
 EndIf 

Return(lRet)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldAC2 �Autor  �Andre Cruz          � Data �  01/09/07   ���
�������������������������������������������������������������������������͹��
���Descricao �Validacoes do Cadastro.                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_VldAC2()
 Local cCodigo := ""
 Local aArea := GetArea()
 Local lRet  := .T.
  
 If ReadVar() == "M->GN1_CODCBO"
  If HS_CountTB("GN1", "GN1_CODCBO = '" + M->GN1_CODCBO + "'") > 0
   lRet := .F.
   HS_MsgInf(STR0010, STR0008, STR0011)  //"J� existe este c�digo cadastrado."###"Aten��o"###"Valida��o do c�digo"
  EndIf
 Else
  cCodigo := &(ReadVar())
  If HS_CountTB("GN1", "GN1_CODCBO = '" + cCodigo + "'") <= 0
   lRet := .F.
   HS_MsgInf(STR0012 + cCodigo + STR0013, STR0008, STR0011)  //"O c�digo ["###"] n�o foi encontrado na CBO."###"Aten��o"###"Valida��o do c�digo"
  EndIf
 EndIf
 
 RestArea(aArea)

Return(lRet)