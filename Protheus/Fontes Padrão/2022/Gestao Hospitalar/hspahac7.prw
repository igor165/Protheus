#INCLUDE "hspahac7.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAC7  �Autor  �Andr� Cruz          � Data �  27/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HSPAHAC7()
 Private aRotina, cCadastro
 cCadastro := STR0001 //"Cadastro de Regras de Credenciamento Taxa/Di�ria"
 aRotina := {{OemtoAnsi(STR0002), "axPesqui", 0, 1},; //"Pesquisar"
             {OemToAnsi(STR0003), "axVisual", 0, 2},; //"Visualizar"
             {OemToAnsi(STR0004), "axAltera", 0, 4}} //"Alterar"

 dbSelectArea("GNB")
 dbSetOrder(1)
 mBrowse(06, 01, 22, 75, "GNB")
 
Return(Nil)
