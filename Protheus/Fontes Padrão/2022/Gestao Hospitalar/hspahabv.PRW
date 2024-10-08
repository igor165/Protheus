#INCLUDE "HSPAHABV.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABV  � Autor � Bruno S. P. Santos � Data �  13/06/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE CONTROLE DE REGRAS DE                          ���
���          � IDENTIFICA��O DA FILIAL DE FATURAMENTO                     ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHABV()                                                         

 Local aTabela := {{"T", "GHZ"}}

 Private aRotina := {{OemtoAnsi(STR0001), "axPesqui" , 0, 1}, ; //"Pesquisar"
                      {OemtoAnsi(STR0002), "HS_ABV"	   , 0, 2}, ;//"Visualizar"
                      {OemtoAnsi(STR0003), "HS_ABV"	   , 0, 4, 4} }//"Alterar"  

 If HS_ExisDic(aTabela) 
 	DbSelectArea("GHZ") 
 	mBrowse(06, 01, 22, 75, "GHZ")
 EndIf
Return(nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_ABV    � Autor � Bruno S. P. Santos � Data �  13/06/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_ABV(cAlias, nReg, nOpc)
 Local nOpcA      := 0
 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela    := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oGHZ

 RegToMemory("GHZ", .F.) //Gera variavies de memoria para o GHZ

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0004) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd//"Controle de regras de identifica��o da filial de faturamento"
  
 oGHZ := MsMGet():New("GHZ", nReg, nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},{"GHZ_PRIORI"},,,,, oDlg)
 oGHZ:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 0
  While __lSX8 
   RollBackSXE()
  End
 ElseIf (nOpcA == 1 .And. nOpcE # 2)
  Begin Transaction
 	 FS_GrvABV(nReg)
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
���Programa  �FS_GrvABV �Autor  � Bruno S. P. Santos � Data �  18/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvABV(nReg)
 Local aArea := GetArea()

	RecLock("GHZ", .F.)
	HS_GrvCpo("GHZ")
	MsUnlock()	

 RestArea(aArea)
Return()