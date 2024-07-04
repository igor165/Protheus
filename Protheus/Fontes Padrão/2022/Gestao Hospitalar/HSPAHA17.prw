#INCLUDE "HSPAHA17.ch"
#include "Protheus.CH"
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA17  � Autor � L.Gustavo Caloi    � Data �  11/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Forma de Administra��o                         ���
�������������������������������������������������������������������������͹��
���Uso       � Prescri��o Eletr�nica                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HSPAHA17()
Private aRotina := {{OemtoAnsi(STR0001), "axPesqui" , 0, 1},; //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_A17"   , 0, 2},; //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_A17"   , 0, 3},; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_A17"   , 0, 4},; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_A17"   , 0, 5} } //"Excluir"

 If HS_LocTab("GFX")
  DbSelectArea("GFX")
  mBrowse(06, 01, 22, 75, "GFX")
 EndIf    
 
Return(Nil) 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A17    � Autor � L.Gustavo Caloi    � Data �  11/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_A17(cAlias, nReg, nOpc)
Local nOpcA := 0

Private nOpcE := aRotina[nOpc, 4]
Private aTela 		:= {}
Private aGets      := {}
Private aHeader    := {}
Private aCols      := {}
Private nUsado     := 0
Private oGFX
Private lGDVazio   := .F.

RegToMemory("GFX",(nOpcE == 3)) //Gera variavies de memoria para o GFX

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Cadastro de Forma de Administra��o"

oGFX := MsMGet():New("GFX", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
oGFX:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIf(nOpcE == 5, FS_Excl17(), .T.), oDlg:End(), nOpcA == 0)}, ;
																																																		{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
 Begin Transaction
  FS_GrvA17(nReg)
 End Transaction
EndIf

Return(Nil)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA17 �Autor  �L.Gustavo Caloi     � Data �  11/09/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FS_GrvA17(nReg)
Local aArea := GetArea()

DbSelectArea("GFX")
If nOpcE <> 3
 DbGoTo(nReg)
Endif

If nOpcE == 3 .Or. nOpcE == 4 //Inclusao e Alterar
  RecLock("GFX", (nOpcE == 3))
  HS_GrvCpo("GFX")
  MsUnlock()
 
ElseIf nOpcE == 5 //Exclusao
 RecLock("GFX", .F.)
 DbDelete()
 MsUnlock()
Endif

RestArea(aArea)
Return()

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_Excl17 � Autor �L.Gustavo Caloi        � Data � 11/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao da Exclusao.                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function FS_Excl17()
Local aArea := GetArea()
Local lRet	 := .T.

If nOpcE == 5  .And. HS_ExisDic({{"T", "GGA"}})  
 If HS_CountTB("GGA", "GGA_CDFORA = '" + M->GFX_CDFORA + "'") > 0
  HS_MsgInf(STR0007 + ". " + STR0012, STR0008, STR0009) //"Forma de Administra��o possui relacionamento com a Apresenta��o de Medicamento"###"Exclus�o n�o permitida"###"Aten��o"###"Valida��o da Exclus�o"
  lRet := .F.
 Endif
Endif

RestArea(aArea)
Return(lRet)
  
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HS_Dupl17 � Autor �L.Gustavo Caloi        � Data � 11/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validar duplicidade.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_Dupl17()
Local lRet := .T.

If Hs_SeekRet("GFX", "M->GFX_CDFORA", 1, .F.,,,,, .T.)
 Hs_MsgInf(STR0010, STR0008, STR0011) //"Este c�digo j� existe"###"Aten��o"###"Valida��o de Inclus�o"
 lRet := .F.
EndIf

Return(lRet)