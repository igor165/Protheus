#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"

Function LOJA1937 ; Return                   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCRetTransacaoCB �Autor  �VENDAS CRM  � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Armazena as informacoes para realizacao de uma transacao  ��� 
���          �utilizando TEF.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCRetTransacaoCB From LJCRetTransacaoCH
    
	Data oDataVenc														//Data de vencimento do titulo/convenio - correspondente bancario
	Data oVlrOrig														//Valor original do titulo/convenio - correspondente bancario
	Data oVlrAcre														//Valor do acrescimo do titulo/convenio - correspondente bancario
	Data oVlrAbat														//Valor do abatimento do titulo/convenio - correspondente bancario
   	Data oVlrPgto														//Valor pago do titulo/convenio - correspondente bancario
   	Data dDataPgto														//Data do pagamento do titulo/convenio - correspondente bancario
	Data cCedente														//Nome do Cedente do titulo/convenio - correspondente bancario
	Data nVlrTotCB														//Valor total dos titulos/convenios pago - correspondente bancario
	Data nTipoDocCB														//Tipo do documento: 0 ' Arrecadacao, 1 ' Titulo (Ficha de compensacao), 2 ' Tributo - correspondente bancario
	Data cCodMod														//tipo da modalidade do pagamento do CB
		
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
Method New() Class LJCRetTransacaoCB 

	_Super:New()
	
	Self:oDataVenc	:= Nil
	Self:oVlrOrig	:= Nil
	Self:oVlrAcre	:= Nil
	Self:oVlrAbat	:= Nil
   	Self:oVlrPgto	:= Nil
   	Self:dDataPgto	:= CtoD("  /  /  ")
	Self:cCedente	:= ""
	Self:nVlrTotCB	:= 0
	Self:nTipoDocCB	:= 0  
	Self:cCodMod	:= ""

Return Self 