#INCLUDE "hspaha49.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA49  � Autor � Patricia Queiroz   � Data �  28/02/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro Tipos de Intercorr�ncias.                         ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA49()

 Private aRotina := {{OemtoAnsi(STR0001), "axPesqui", 0, 1}, ;   //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_A49"		, 0, 2}, ;   //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_A49"		, 0, 3}, ;   //"Incluir"
                     {OemtoAnsi(STR0004), "HS_A49"		, 0, 4}, ;   //"Alterar"
                     {OemtoAnsi(STR0005), "HS_A49"		, 0, 5}}     //"Excluir"
                      
 DbselectArea("GHM")                     
                    
 mBrowse(06, 01, 22, 75, "GHM") 
 
Return(Nil)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A49    � Autor � Patricia Queiroz   � Data �  28/02/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_A49(cAliasA49, nRegA49, nOpcA49)   

 Local nOpcA := 0

 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private oGHM
 
 RegToMemory("GHM", (aRotina[nOpcA49, 4] == 3)) 

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd    //"Tipo de Intercorr�ncias"

 oGHM := MsMGet():New("GHM", nRegA49, nOpcA49,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGHM:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(aRotina[nOpcA49, 4] == 5, FS_VldExc(), .T.), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. aRotina[nOpcA49, 4] <> 2
  Begin Transaction
   FS_GrvA49(nOpcA49)
  End Transaction 
  While __lSx8
   ConfirmSx8()
  EndDo  
 Else
  While __lSx8
   RollBackSx8()
  EndDo     
 EndIf
 
Return(Nil)
 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA49 �Autor  �Patricia Queiroz    � Data �  28/02/07   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA49(nOpcA49)

If aRotina[nOpcA49, 4] == 3 .Or. aRotina[nOpcA49, 4] == 4 //Incluir e Alterar
 If aRotina[nOpcA49, 4] == 3
  M->GHM_CDINTE := HS_VSxeNum("GHM", "M->GHM_CDINTE", 1)                     	
 EndIf 
 RecLock("GHM", (aRotina[nOpcA49, 4] == 3))
  HS_GrvCpo("GHM")
 MsUnlock()	
ElseIf aRotina[nOpcA49, 4] == 5 //Excluir
 RecLock("GHM", .F.)
  DbDelete()
 MsUnlock()
EndIf

Return(.T.)  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValEx  �Autor  �Patricia Queiroz    � Data �  28/02/07   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validar a exclusao.                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                           
Static Function FS_VldExc()

Local aArea := GetArea()
Local lRet	 := .T.

If HS_CountTB("GHK", "GHK_CDINTE = '" + GHM->GHM_CDINTE + "'") > 0
	HS_MsgInf(STR0007, STR0008, STR0009)  //"O registro possui relacionamento com Coleta."###"Aten��o"###"Valida��o de Exclus�o"
 lRet := .F.	
EndIf
 
RestArea(aArea)

Return(lRet)