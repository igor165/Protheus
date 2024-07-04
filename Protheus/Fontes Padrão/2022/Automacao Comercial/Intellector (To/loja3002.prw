#INCLUDE "MSOBJECT.CH"

Function LOJA3002 ; Return  // "dummy" function - Internal Use 

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������         
���������������������������������������������������������������������������������ͻ��
���Classe    �LJCDadosEnvYMF	�Autor  �Vendas Clientes     � Data �  01/12/09   ���
���������������������������������������������������������������������������������͹��
���Desc.     �Interface da classe LJCYMF, os metodos precisam ser implementados   ���
���			 �na classe LJCYMF.    	    										  ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                         		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/
Class LJCDadosEnvYMF
    
    Data cValorLimi										//Valor do Limite de Credito
	Data cDataVenda										//Data da Venda    										
	Data cDataVenc                                      //Data do Vencimento do Limite de Credito
	Data cTitulosAb                                     //Titulos Abertos
	Data cTolLimite										//Tolerancia do Limite
	Data cValorFinc                                     //Valor Financiado
	Data cValorTitA                                     //Valor dos Titulos em Atraso
	Data oCliente                                       //Dados do Cliente (SA1) do Tipo LJCEntCliente
	               
	Method New()                                        //Construtor da Classe.

End Class

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New       �Autor  �Microsiga           � Data �  01/12/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo Construtor.                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Sigaloja / Frontloja                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCDadosEnvYMF
    
    Self:cValorLimi  := ""
	Self:cDataVenda  := ""
	Self:cDataVenc   := ""
	Self:cTitulosAb  := ""
	Self:cTolLimite  := ""
	Self:cValorFinc  := ""
	Self:cValorTitA  := ""
	Self:oCliente    := Nil

Return Self 
