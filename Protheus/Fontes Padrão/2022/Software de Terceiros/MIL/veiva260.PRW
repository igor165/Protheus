#INCLUDE "rwmake.ch" 
#INCLUDE "veiva260.ch" 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VEIVA260  � Autor � ALEXANDRE          � Data �  21/05/07   ���
�������������������������������������������������������������������������͹��
���Descricao � cadastr de classificacao de compra e venda                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function VEIVA260
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString := "VAV"
dbSelectArea("VAV")
dbSetOrder(1)
AxCadastro(cString,STR0001,cVldExc,cVldAlt) //Cadastro de Classificacao de compra e venda
Return

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)