#include "OfiGA070.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � OFIGA070 � Autor �  Emilton              � Data � 15/04/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Erros/Laudos                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIGA070

Private cCadastro := OemToAnsi(STR0006)

axCadastro("VGD", cCadastro,"GA070E()")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GA070E    �Autor  � Emilton            � Data �  11/04/02   ���
�������������������������������������������������������������������������͹��
���Desc.     � Excluir                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Garantia                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function GA070E()
/* Ainda nao existe a tabela que esta validacao sera necessaria
Local aVetValid := {}
aAdd(aVetValid, {"VG5", "VG5_CODMAR+VG5_CODFOR" , VG7->VG7_CODMAR+VG7->VG7_CODFOR , NIL } )
Return FG_DELETA( aVetValid )
*/
Return .t.

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)