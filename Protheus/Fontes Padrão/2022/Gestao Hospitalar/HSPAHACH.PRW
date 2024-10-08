#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHACH  � Autor � Bruno S. P. Santos � Data �  17/09/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro Recursos                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHACH()
 Local aTabela := {{"T", "GNZ","FNC 148152"}}

 Private aRotina := {{OemtoAnsi("Pesquisar") , "axPesqui" , 0, 1}, ;
                      {OemtoAnsi("Visualizar"), "HS_ACHROT"	 , 0, 2}, ;
                      {OemtoAnsi("Incluir")   , "HS_ACHROT"	 , 0, 3}, ; 
                      {OemtoAnsi("Alterar")   , "HS_ACHROT"	 , 0, 4}, ; 
                      {OemtoAnsi("Excluir")   , "HS_ACHROT"	 , 0, 5} }  

 If HS_ExisDic(aTabela) 
 	DbSelectArea("GNZ") 
 	mBrowse(06, 01, 22, 75, "GNZ")
 EndIf                        
Return(nil)                  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_ACHROT � Autor � Bruno S. P. Santos � Data �  17/09/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_ACHROT(cAlias, nReg, nOpc)
 Local nOpcA      := 0
 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela    := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oGNZ

 RegToMemory("GNZ",(nOpcE == 3)) 

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi("Cadastro de Recursos") From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd

 oGNZ := MsMGet():New("GNZ", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGNZ:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_ExclGNZ(), .T.), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 0
  While __lSX8 
   RollBackSXE()
  End
 ElseIf (nOpcA == 1 .And. nOpcE # 2)
  Begin Transaction
 	 FS_GrvACH(nReg)
  End Transaction  
  While __lSX8
   ConfirmSX8()
  End
 EndIf
Return(nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvACH �Autor  � Bruno S. P. Santos � Data �  17/09/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvACH(nReg)
Local aArea := GetArea()

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
	RecLock("GNZ", (nOpcE == 3))
	 HS_GrvCpo("GNZ")
	MsUnlock()	
ElseIf nOpcE == 5 //Exclusao
	RecLock("GNZ", .F.)
	 DbDelete()
	MsUnlock()  
 WriteSx2("GNZ")	
Endif                   

RestArea(aArea)
Return()
                  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_ExclGNZ� Autor �Bruno S. P. Santos     � Data � 18/04/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao da Exclusao.                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ExclGNZ()
Local aArea := GetArea()
Local lRet	 := .T.

If (HS_CountTB("GM8", "GM8_CODREC = '" + M->GNZ_CODREC + "'")  > 0) 
 HS_MsgInf("Recurso possu� agendamentos gerados. Verifique!", "Aten��o", "Valida��o da Exclus�o") 
	lRet := .F.
Endif                                                                   
                                                                                                                      
RestArea(aArea)
Return(lRet)   