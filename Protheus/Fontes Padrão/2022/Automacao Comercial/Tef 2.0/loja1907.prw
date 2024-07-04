#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"        

Function LOJA1907 ; Return     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJICCCD      �Autor  �VENDAS CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Interface para transcao com cartao de credito e cartao de ��� 
���          �debito.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJICCCD

	Method Credito(oDadosTran)
	Method CreditoPar(oDadosTran)
	Method Debito(oDadosTran)
	Method DebitoPar(oDadosTran)
	Method DebitoPre(oDadosTran)
	Method Confirmar()
	Method Desfazer()
	Method FuncoesAdm(oDadosTran)
	Method GetTrans()
	Method CupomReduz()

EndClass