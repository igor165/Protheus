#Include "Protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TMSA340H � Autor � Vitor Raspa           � Data � 22.Dez.06���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Encerramento de Viagens de Entrega Fluvial                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSA340H()                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TMSA340H()

Local cSerTms := StrZero(3,Len(DTQ->DTQ_SERTMS))
Local cTipTra := StrZero(3,Len(DTQ->DTQ_TIPTRA))

Private aRotina := MenuDef()

TMSA340(cSerTms,cTipTra)

Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MENUDEF  � Autor � Jefferson Tomaz       � Data �29.12.2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Menu                                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRotina := MenuD340()

Return(aRotina)