#INCLUDE "hspahab7.ch"
#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAB7  � Autor �Alessandro Freire   � Data �  02/03/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de livros fiscais                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Livros para receita federal                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHAB7()


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := "HS_AB7Vld()" // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := "HS_AB7Vld()" // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "GED"

dbSelectArea("GED")
dbSetOrder(1)

AxCadastro(cString,STR0001,cVldAlt,cVldExc) //"Cadastro de livros"

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_AB7VLD �Autor  � Alessandro Freire  � Data �  02/03/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida se o livro pode ser alterado ou exclu�do            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION HS_AB7Vld()

If Inclui .or. Altera
	If M->GED_PAGINI > 0
		HS_MsgInf(STR0002,STR0003,STR0004) //"Este livro n�o pode mais ser alterado e nem exclu�do. Garantia de Integridade"###"Atencao"###"Cadastro de Livros Fiscais"
		Return(.f.)
	EndIf
Else
	If GED->GED_PAGINI > 0
		HS_MsgInf(STR0002,STR0003,STR0004) //"Este livro n�o pode mais ser alterado e nem exclu�do. Garantia de Integridade"###"Atencao"###"Cadastro de Livros Fiscais"
		Return(.f.)	
	Endif
Endif
Return(.t.)   
