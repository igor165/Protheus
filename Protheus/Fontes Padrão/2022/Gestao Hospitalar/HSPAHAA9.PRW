#INCLUDE "HSPAHAA9.ch"
#include "protheus.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAA9  � Autor � Daniel Peixoto     � Data �  17/02/06   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE SITIOS ESPECIFICOS                        			  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHAA9()
 Private cAlias := "GEW"
 DbSelectArea(cAlias)
 DbSetOrder(1)
 AxCadastro(cAlias, STR0001,  "Fs_ExcA9()")   //"Cadastro de Sitios Especificos"
Return

// Funcao de Exclusao
Function Fs_ExcA9()
 Local lRet := .T.
 DbSelectArea("GEL")
 DbSetOrder(1)
 If DbSeek(xFilial("GEL") + GEW->GEW_CODIGO)
  HS_MsgInf(STR0002,STR0003,STR0001) //"Este Codigo esta sendo usado no Cadastro de Sitios Principais. Impossivel Exclui-lo!"###"Atencao"###"Cadastro de Sitios Especificos"
  lRet := .F.
 Endif
 DbSelectArea(cAlias)
Return(lRet)
