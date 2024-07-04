#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"

Function LOJA1953 ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadosTransacaoCheque  �Autor  �Vendas Clientes     � Data �  11/02/10   ���
����������������������������������������������������������������������������������������͹��
���Desc.     �Dados da transacao de cheque			         							 ���
����������������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		         ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCDadosTransacaoCheque From LJADadosTransacao
   	
   	Data nBanco														//Numero do banco
   	Data nAgencia													//Numero da agencia
   	Data nConta														//Numero da conta
   	Data nCheque													//Numero do cheque
   	Data nC1														//C1
   	Data nC2														//C2
   	Data nC3														//C3
   	Data dDataVcto													//Data de vencimento
   	Data nCompensa													//Compensacao
   	Data cTipoCli													//Tipo do Cliente
   	Data cCNPJ														//CNPJ/CGC Cliente  
   	Data cRede														//Rede da transacao
  	   		   			
	Method New()													//Metodo construtor  
	
	
EndClass

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Metodo    �New   	       �Autor  �Vendas Clientes     � Data �  11/02/10   ���
��������������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCDadosTransacaoCheque.	    	     ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������͹��
���Parametros�EXPN1 (1 - nValor) - Valor da transacao   				 		 ���
���			 �EXPN2 (2 - nCupom) - Numero de identificacao da transacao   		 ���
���			 �EXPD1 (3 - dData) - Data da transacao   							 ���
���			 �EXPC1 (4 - cHora) - Hora da transacao				   				 ���
��������������������������������������������������������������������������������͹��
���Retorno   �Objeto														     ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Method New(nValor	, nCupom	, dData	, cHora		, ;
		   nBanco	, nAgencia	, nConta, nCheque	, ;
		   nC1		, nC2		, nC3	, dDataVcto	, ;
		   nCompensa, cTipoCli	, cCNPJ,  lUltimaTrn,;
		   cRede) Class LJCDadosTransacaoCheque
    
    _Super:New(nValor, nCupom, dData, cHora, _CHEQUE, lUltimaTrn, cRede)
	
	::nBanco		:= nBanco
   	::nAgencia		:= nAgencia
   	::nConta		:= nConta
   	::nCheque		:= nCheque
   	::nC1			:= nC1
   	::nC2			:= nC2
   	::nC3			:= nC3
   	::dDataVcto		:= dDataVcto   	
   	::nCompensa		:= nCompensa   
   	::cTipoCli		:= cTipoCli											//Tipo do Cliente
   	::cCNPJ			:= cCNPJ											//CNPJ/CGC Cliente
   	
Return Self  