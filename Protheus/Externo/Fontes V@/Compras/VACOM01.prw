#include "topconn.ch"
#include "protheus.ch" 
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � VACOM01 Autor � Henrique Magalhaes   � Data � 19.06.2015�  ��
�������������������������������������������������������������������������Ĵ��
��� Descri��o � AxCadastro para SD1 - ITENS DE NOTAS FISCAIS             ���
�������������������������������������������������������������������������Ĵ��
���Uso       �  Usado para usuario poder filtrar/exportar excel           ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function VACOM01()
Local   aArea 		:= GetArea()  
Private cCadastro	:= "Itens de Notas Fiscais"
Private aRotina		:= {}
 
//AxCadastro( <cAlias>, <cTitulo>, <cVldExc>, <cVldAlt>)
AxCadastro("SD1", OemToAnsi(cCadastro), '.F.','.F.')
Restarea(aArea)
Return    

