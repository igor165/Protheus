#INCLUDE "hspaha26.ch"
#include "Protheus.CH"
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA26  � Autor � L.Gustavo Caloi    � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Modo de Infus�o                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Prescri��o Eletr�nica                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HSPAHA26()
Private aRotina := {{OemtoAnsi(STR0001), "axPesqui" , 0, 1},; //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_A26"   , 0, 2},; //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_A26"   , 0, 3},; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_A26"   , 0, 4},; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_A26"   , 0, 5} } //"Excluir"
 If HS_LocTab("GFY")
  DbSelectArea("GFY")
  mBrowse(06, 01, 22, 75, "GFY")
 EndIf 

Return(Nil) 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A26    � Autor � L.Gustavo Caloi    � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_A26(cAlias, nReg, nOpc)
Local nOpcA := 0

Private nOpcE := aRotina[nOpc, 4]
Private aTela 		:= {}
Private aGets      := {}
Private aHeader    := {}
Private aCols      := {}
Private nUsado     := 0
Private oGFY
Private lGDVazio   := .F.

RegToMemory("GFY",(nOpcE == 3)) //Gera variavies de memoria para o GFY

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Cadastro de Modo de Infus�o"

oGFY := MsMGet():New("GFY", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGFY:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_Excl26(), .T.), oDlg:End(), nOpcA == 0)}, ;
																																																		{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
 Begin Transaction
  FS_GrvA26(nReg)
 End Transaction
EndIf

Return(Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA26 �Autor  �L.Gustavo Caloi     � Data �  13/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FS_GrvA26(nReg)
Local aArea := GetArea()

DbSelectArea("GFY")
If nOpcE <> 3
 DbGoTo(nReg)
Endif

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
 RecLock("GFY", (nOpcE == 3))
 HS_GrvCpo("GFY")
 MsUnlock()

ElseIf nOpcE == 5 //Exclusao
 RecLock("GFY", .F.)
 DbDelete()
 MsUnlock()
Endif

RestArea(aArea)
Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_Excl26 � Autor �L.Gustavo Caloi        � Data � 13/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao da Exclusao.                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FS_Excl26()
Local aArea := GetArea()
Local lRet	 := .T.

If nOpcE == 5 .And. HS_ExisDic({{"T", "GGD"}})  
 If HS_CountTB("GGD", "GGD_CDMINF = '" + M->GFY_CDMINF + "'") > 0
  HS_MsgInf(STR0007 + STR0012, STR0008, STR0009) //"O Modo de Infus�o possui relacionamento com Diluente de Medicamento. "###"Exclus�o n�o permitida"###"Aten��o"###"Valida��o da Exclus�o"
  lRet := .F.
 Endif
Endif

RestArea(aArea)
Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HS_Dupl26 � Autor �L.Gustavo Caloi        � Data � 11/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validar duplicidade.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_Dupl26()
Local lRet := .T.

If Hs_SeekRet("GFY", "M->GFY_CDMINF", 1, .F.,,,,, .T.)
 Hs_MsgInf(STR0010, STR0008, STR0011) //"Este c�digo j� existe"###"Aten��o"###"Valida��o de Inclus�o"
 lRet := .F.
EndIf

Return(lRet)