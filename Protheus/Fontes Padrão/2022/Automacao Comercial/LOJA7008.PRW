#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"



Function LOJA7008 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    |LjClSE5          �Autor  �Vendas Clientes     � Data �  03/12/2010 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe Pagamentos dos t�tulos								         ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LjClSE5
   	
	Data cChave //Chave do SE5 E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+E5_RECPAG                                                                                                                                                                                             
	Data nIndice //Indice da chave do SE5 := 7
	Data cE5_TIPODOC //Tipo do Documento
	Data dE5_DATA //Data da movimenta��o
	Data cE5_AGENCIA  //Agencia da Conta
	Data cE5_TIPO //Tipo do T�tulo  
	Data nE5_VALOR //Valor do Lan�amento        
	Data cE5_BANCO //C�digo do Banco   
	Data cE5_CONTA //Conta Corrente do Banco
	Data cE5_RECPAG //Recebimento ou Pagamento 
	Data cE5_MOTBX //Motivo da Baixa do T�tulo

	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA7008  �Autor  �Microsiga           � Data �  03/12/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method New()  
	    
EndClass  


/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |New              �Autor  �Fabiana Cristina     � Data �  03/12/2010 ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que Instancia o objeto                                       ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja                                                     		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method New(cChave, nIndice)  Class LjClSE5  

	Self:cChave := cChave //Chave do SE1E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
	Self:nIndice := nIndice //Indice da chave do SE1 =:1
	Self:cE5_TIPODOC := ""//Tipo do Documento
	Self:dE5_DATA := nil//Data da movimenta��o
	Self:cE5_AGENCIA := "" //Agencia da Conta
	Self:cE5_TIPO := ""//Tipo do T�tulo  
	Self:nE5_VALOR := 0//Valor do Lan�amento        
	Self:cE5_BANCO := ""//C�digo do Banco   
	Self:cE5_CONTA := ""//Conta Corrente do Banco
	Self:cE5_RECPAG := ""//Recebimento ou Pagamento 
	Self:cE5_MOTBX := ""//Motivo da Baixa do T�tulo

Return Nil  
