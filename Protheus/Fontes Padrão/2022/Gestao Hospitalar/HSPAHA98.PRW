#INCLUDE "HSPAHA98.ch"
#include "protheus.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA98  � Autor � Gilson da Silva    � Data �  19/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE UNIDADE DE CONSUMO.   																							  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA98()
 Private cAlias := "GCT"
 DbSelectArea(cAlias)
 DbSetOrder(1)
 AxCadastro(cAlias, STR0001, "Fs_Exc98()") //"Cadastro de Unidade de Consumo"
Return

// Funcao de Exclusao
Function Fs_Exc98()
 Local lRet := .T.
 DbSelectArea("GCS")
 DbSetOrder(2)
 If DbSeek(xFilial("GCS") + GCT->GCT_CODUNC)
  HS_MsgInf(STR0002, STR0003, STR0004)     //"Este Codigo esta sendo usado pela Tabela de Setor. Impossivel Exclui-lo!"###"Atencao"###"Exclus�o n�o Permitida"
  lRet := .F.
 Endif
 DbSelectArea(cAlias)
Return(lRet)