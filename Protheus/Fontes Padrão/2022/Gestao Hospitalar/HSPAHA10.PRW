#INCLUDE "HSPAHA10.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA10  � Autor � Manoel             � Data �  23/11/01   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE GRUPO DE FARMACOS                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ�� 
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA10()
 Private cAlias := "GAN"
 DbSelectArea(cAlias)
 DbSetOrder(1)
 AxCadastro(cAlias, STR0001,"HS_VEA10()") //"Cadastro de Farmacos"
Return

Function HS_VEA10()
 Local lRet := .T.
 DbSelectArea("GBI")
 DbSetOrder(2)
 If DbSeek(xFilial("GBI") + GAN->GAN_GRUFAR)
  HS_MsgInf(STR0002, STR0003, STR0001) //"Existe este Grupo de Farmaco em algum Produto do Cadastro de Produtos (GBI). Impossivel Exclui-lo!"###"Aten��o"###"CADASTRO DE GRUPO DE FARMACOS"
  lRet := .F.
 EndIf
 DbSelectArea(cAlias)
Return(lRet)