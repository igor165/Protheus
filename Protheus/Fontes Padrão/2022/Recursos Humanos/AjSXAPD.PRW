#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��                 
���Programa    �AjSXAPD    �Autor    �Inova��o - RH       � Data �  29/06/2015 ���
������������������������������������������������������������������������������͹��
���Desc.       � Fonte respons�vels pelos ajustas na vers�o p12.               ���
���            �                                                               ���
������������������������������������������������������������������������������͹��
���Programador � DATA      � Chamado     �  MOTIVO DA ALTERACAO                ���
���Matheus M.  � 20/09/2016� TVWCPN      � Ajustes para a descri��o do browse  ���
���            �           �             � na tabela de QUEST�ES n�o duplicar  ���
���            �           �             � os campos.                          ���
��� Isabel N.  � 25/04/2017� DRHPONTP-96 �Ajuste no campo RD8_HABIL p/ trazer a���
���            �           �             �RBJ ao inv�s da RBG na Cons.Padr�o.  ���
��� Willian U. � 08/06/2017� DRHPONTP-59 �Tratamento da m�scara de senha       ���
���            �           �             �(DRHPONTP-334) transferido para o fon���
���            �           �             �te AjSXAPD.PRW por se tratar de alte ���
���            �           �             �ra��o do dicion�rio e altera��o na   ���
���            �           �             �valida��o do campo RD0_PERMAD para   ���
���            �           �             �aceitar vazio.                       ���
��� Willian U. � 10/07/2017� DRHPONTP-29 �Ajuste no inicializador padr�o e no  ���
���            �           �             �inicializador do browser do campo    ���
���            �           �             �QO_MEMO (Descri��o Detalhada).       ���
���Isabel N.   � 25/07/2017�DRHPONTP-360 �Ajuste/Limpeza do fonte para 12.1.17.���
���Isabel N.   � 02/08/2017�DRHPONTP-1214�Ajuste nos inicializadores do campo  ���
���            �           �             �RBJ_DHABIL p/considerar filial certa.���
��������������������ͱ��������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/ 

Main function APDLoad()
Local lRet := .T.

lRet := fChkConv12()
If !lRet
	Return
Endif

Return (.T.)
