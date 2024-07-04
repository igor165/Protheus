#INCLUDE "PROTHEUS.CH"        

Function LOJA1936 ; Return             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCRetTransacaoCH �Autor  �VENDAS CRM  � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Armazena as informacoes para realizacao de uma transacao  ��� 
���          �utilizando TEF.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCRetTransacaoCH From LJARetTransacaoTef

	Data cAutentica														//Dados para autenticacao 
	Data nBanco															//Numero do banco
   	Data nAgencia														//Numero da agencia
   	Data nConta															//Numero da conta
   	Data nCheque														//Numero do cheque
   	Data nC1															//C1
   	Data nC2															//C2
   	Data nC3															//C3
   	Data nCompensa														//Compensacao
	Data nTipoDocCh														//Tipo do Documento a ser consultado (0 - CPF, 1 - CGC)
	Data cCPFCGC														//Numero do documento (CPF ou CGC)
	Data cTelefone														//Numero do telefone

	
	Method New()

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
Method New() Class LJCRetTransacaoCH 
	
	_Super:New()
	
	Self:cAutentica	:= ""
	Self:nBanco		:= 0
   	Self:nAgencia	:= 0
   	Self:nConta		:= 0
   	Self:nCheque	:= 0
   	Self:nC1		:= 0
   	Self:nC2		:= 0
   	Self:nC3		:= 0
   	Self:nCompensa	:= 0
   	Self:nTipoDocCh	:= 0
   	Self:cCPFCGC	:= ""
   	Self:cTelefone	:= ""    
 


Return Self 