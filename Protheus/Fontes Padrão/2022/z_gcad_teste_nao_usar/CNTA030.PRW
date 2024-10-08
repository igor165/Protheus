#INCLUDE "CNTA030.ch"        
Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CNTA030  � Autor � Marcelo Custodio      � Data �22.11.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Manutencao dos Motivos de Paralisacao de Contrato          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CNTA030()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CNTA030()

AxCadastro("CN2",STR0001,"CN030DEL()")

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � CN030DEL � Autor � Marcelo Custodio      � Data �22.11.2005���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Validacao da exclusao do motivo de paralisacao             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CN030DEL()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CN030DEL()
Local lRet := .T.

dbSelectArea("CN9") 
dbSetOrder(6)//Motivo de Paralisacao

//�������������������������������������������������������������������������Ŀ
//�Valida a existencia do registro no cadastro de contratos                 �
//���������������������������������������������������������������������������
If MsSeek(xFilial('CN9')+CN2->CN2_CODIGO, .F.)
	lRet := .F.
	Help( " ", 1, "CNTA030_01" )
Endif                    

return lRet