#INCLUDE "PROTHEUS.CH"        

Function LOJA1901 ; Return  // "dummy" function - Internal Use 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCCreditoDebito�Autor  �VENDAS CRM    � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Interface para transcao com cartao de credito e cartao de ��� 
���          �debito.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCCreditoDebito

Data oCCCD

Method New(oCCCD) Constructor
EndClass  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oCCCD) Class LJCCreditoDebito 
Self:oCCCD := oCCCD 
Return Self  