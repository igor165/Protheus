#INCLUDE "plsatmk.ch"
#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PLSATMK   � Autor � David de Oliveira  � Data �  12/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao � "Fun��es PLS x Ocorr�ncias Call Center"                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PLSATMK()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Private cCadastro := STR0001 //"Fun��es PLS x Ocorr�ncias Call Center"


Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private aRotina := MenuDef()
Private cString := "B20"

dbSelectArea(cString)
dbSetOrder(1)

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)

Return

Static Function MenuDef()

Local aRotina:={ {STR0002,"AxPesqui",0,1} ,; //"Pesquisar"
             {STR0003,"AxVisual",0,2} ,; //"Visualizar"
             {STR0004,"AxInclui",0,3} ,; //"Incluir"
             {STR0005,"AxAltera",0,4} ,; //"Alterar"
             {STR0006,"AxDeleta",0,5} } //"Excluir"

Return(aRotina)
