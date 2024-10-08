#INCLUDE "HSPAHA46.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA46  � Autor � Patricia Queiroz   � Data �  28/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro Motivos de Descarte                               ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA46()

 Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui", 0, 1}, ;  //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_A46"		, 0, 2}, ;  //"Visualizar"
                      {OemtoAnsi(STR0003), "HS_A46"		, 0, 3}, ;  //"Incluir"
                      {OemtoAnsi(STR0004), "HS_A46"		, 0, 4}, ;  //"Alterar"
                      {OemtoAnsi(STR0005), "HS_A46"		, 0, 5}}    //"Excluir"
                      
 DbselectArea("GGS")                     
                    
 mBrowse(06, 01, 22, 75, "GGS") 
 
Return(Nil)



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A46    � Autor � Patricia Queiroz   � Data �  28/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_A46(cAlias, nReg, nOpc)   

 Local nOpcA := 0

 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private oGGS
 
 RegToMemory("GGS", (aRotina[nOpc, 4] == 3)) 

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Motivos de Descarte"

 oGGS := MsMGet():New("GGS", nReg, nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGGS:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(aRotina[nOpc, 4] == 5, FS_ValEx(), .T.), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. aRotina[nOpc, 4] <> 2
  Begin Transaction
   FS_GrvA46(nOpc)
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
���Programa  �FS_GrvA46 �Autor  �Patricia Queiroz    � Data �  28/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA46(nOpc)

If aRotina[nOpc, 4] == 3 .Or. aRotina[nOpc, 4] == 4 //Incluir e Alterar
 If aRotina[nOpc, 4] == 3
  M->GGS_CDMOTI := HS_VSxeNum("GGS", "M->GGS_CDMOTI", 1)                     	
 EndIf 
 RecLock("GGS", (aRotina[nOpc, 4] == 3))
 HS_GrvCpo("GGS")
 MsUnlock()	
ElseIf aRotina[nOpc, 4] == 5 //Excluir
 RecLock("GGS", .F.)
 DbDelete()
 MsUnlock()
EndIf

Return(.T.)  


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValEx  �Autor  �Patricia Queiroz    � Data �  28/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validar a exclusao.                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                           
Static Function FS_ValEx()

Local aArea := GetArea()
Local lRet	 := .T.

If HS_CountTB("GGO", "GGO_CDMOTI = '" + GGS->GGS_CDMOTI + "'") > 0
	HS_MsgInf(STR0007, STR0008, STR0009) //"O registro possui relacionamento com Coleta."###"Aten��o"###"Valida��o de Exclus�o"
 lRet := .F.	
EndIf
 
RestArea(aArea)

Return(lRet)