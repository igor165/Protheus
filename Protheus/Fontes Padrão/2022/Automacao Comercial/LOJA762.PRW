#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA762; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadNeg        �Autor  �Vendas Clientes     � Data �  15/10/07   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe responsavel em manipular um arquivo.                   	 ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LJCDadNeg

	Data nItem
	Data cCodigo
	Data cItemNeg
	Data cProduto
	Data cFormPag
	Data cAdm
	Data nPacelar
	Data nValor

	Method New()

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �New       �Autor  �Vendas Clientes     � Data �  15/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Construtor da classe LJC_DadosCDes. 				          ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
���          �  			      										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(nSeq, cCodigo,  cItemNeg, cFormPag, cAdm, nPacelar, nValor )Class LJCDadNeg

	Default nSeq		:= 0   		
	Default cCodigo		:= ''		
	Default cItemNeg	:= ''		
	Default cFormPag	:= ''       
	Default cAdm        := ''
	Default nPacelar	:= 0
	Default nValor		:= 0

	Self:nItem		:= nSeq
	Self:cCodigo	:= cCodigo
	Self:cItemNeg   := cItemNeg
	Self:cFormPag	:= cFormPag
	Self:cAdm       := cAdm
	Self:nPacelar	:= nPacelar
	Self:nValor		:= nValor

Return()                                                                            	