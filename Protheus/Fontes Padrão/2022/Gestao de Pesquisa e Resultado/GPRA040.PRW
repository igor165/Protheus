#INCLUDE "GPRA040.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GPRA040  � Autor �  Henry Fila           � Data � 22/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastro de Entrevistadores                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION GPRA040
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������

PRIVATE cCadastro := OemToAnsi(STR0001) //"Entrevistador"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao axCadastro                                 �
//����������������������������������������������������������������
dbSelectArea("SKN")
axCadastro("SKN", cCadastro,"Gpr040Del()")

Return .T.     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Gpr040Del� Autor �  Henry Fila           � Data � 22/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao da exclusao de entrevistadores                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���Henry F   �29/08/07�      �FNC 002630/2005 - Validacao da exclusao do  ���
���          �        �      �entrevistador                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Gpr040Del()

Local aArea := GetArea()	//Salva o ambiente altual
Local lRet  := .T.			//Controle da variavel de retorno

If !Empty( GprxPEntr( SKN->KN_CODPES, .F. )[1][1] )
	Help( " ", 1, "NODELETA")
	lRet := .F.
Endif	

RestArea( aArea )
                 
Return( lRet )

 