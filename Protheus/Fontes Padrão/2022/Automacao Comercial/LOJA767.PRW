#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA767; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCCabRetNeg     �Autor  �Vendas Clientes     � Data �  15/01/11   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCCabRetNeg

	Data cCodigo
	Data cDescricao
	Data dValidade
	Data nValor
                               
	Method New()

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJCCabRetNeg. 				          ���
�������������������������������������������������������������������������͹��
���Parametros�cExp1 -Codigo Mn											  ���
���          �nExp2 -vALOR DA mN			  							  ��� 
���          �cExp2 -Descricao Mn			  							  ���
���          �dExp2 -Validade				  							  ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(cCodigo, nValor, cDescricao, dValidade )Class LJCCabRetNeg

	Default cCodigo		:= ""   		
	Default nValor		:= 0
	Default cDescricao	:= ""
	Default dValidade  	:= dDataBase

	Self:cCodigo	:= cCodigo
	Self:cDescricao	:= cDescricao	
	Self:dValidade	:= dValidade
	Self:nValor		:= nValor

Return()                                                                            	