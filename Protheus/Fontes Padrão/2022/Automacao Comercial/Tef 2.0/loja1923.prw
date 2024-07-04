#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"        

Function LOJA1923 ; Return     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJIPBM       �Autor  �VENDAS CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface para transacao com PBM							  ��� 
���          �debito.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       �MP10	                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJIPBM

	Method IniciaVend(oDadosTran)
	Method VendProd(cCodBarra, nQtde, nPrUnit, nPercDesc, lItemPbm)
	Method CancProd(cCodBarra, nQtde)
	Method FinalVend(oDadosTran)
	Method BuscaSubs()
	Method ConfProd(cCodBarra, nQtde, lOK)
	Method CancPbm(oDadosTran)
	Method SelecPbm()
	Method Confirmar()
	Method Desfazer()
	Method GetTrans()
	Method IniciouVen()

EndClass