#INCLUDE "PROTHEUS.CH"
#INCLUDE "CNTA190.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CNTA190  � Autor � TOTVS                 � Data � 06/07/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Ocorrencias Avaliacoes da Execucao Contratos   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CNTA190()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico					 								  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CNTA190()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "COB"

dbSelectArea("COB")
dbSetOrder(1)
AxCadastro(cString,OemToAnsi(STR0001),cVldExc,cVldAlt)	//"Cadastro de Ocorrencias da Avaliacao de Execucao de Contratos"

Return
