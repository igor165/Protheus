#INCLUDE "PROTHEUS.CH"

Function LOJA1934 ; Return                     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJARetTransacaoTef�Autor  �VENDAS CRM  � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Armazena as informacoes para realizacao de uma transacao  ��� 
���          �utilizando TEF.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJARetTransacaoTef
	
	Data oViaCaixa
	Data oViaCliente
	Data cViaCaixa
	Data cViaCliente
	Data lTransOk
	Data dData
	Data cHora
	Data cAutoriz
	Data cNsu
	Data cId
	Data cFinalizacao 
	Data cRede 
	Data cDocCanc
	Data dDataCanc
	Data cNsuAutor	
	Data aAdmin
	Data nVlrSaque
	Data nVlrVndcDesc
	Data nVlrDescTEF
	Data nParcs 
	Data cCelular 
	Data cIdtransaction													//ID da Transa��o
	Data cProcessorTransactionId										//ID da transa��o do processador
	Data cExternalTransactionId											//ID da transa��o Externa
	Data cErrorReason													//Raz�o do erro

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
Method New() Class LJARetTransacaoTef 

	Self:oViaCaixa					:= Nil
	Self:oViaCliente				:= Nil
	Self:cViaCaixa					:= ""
	Self:cViaCliente				:= ""
	Self:lTransOk					:= .F.
	Self:dData						:= Date()
	Self:cHora						:= Time()
	Self:cAutoriz					:= ""
	Self:cNsu						:= ""
	Self:cId						:= ""
	Self:cFinalizacao				:= ""
	Self:cRede						:= ""   
	Self:cNsuAutor      			:= ""
	Self:cDocCanc       			:= ""
	Self:dDataCanc      			:= "" 
	Self:aAdmin						:= {}
	Self:nVlrSaque					:= 0
	Self:nVlrVndcDesc				:= 0
	Self:nVlrDescTEF				:= 0
	Self:nParcs						:= 0
	Self:cCelular					:= ""
	Self:cIdtransaction				:= ""
	Self:cProcessorTransactionId	:= ""
	Self:cExternalTransactionId		:= ""
	Self:cErrorReason				:= ""
	
Return Self 
