#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1908 ; Return             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJACCCD      �Autor  �VENDAS CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Interface para transcao com cartao de credito e cartao de ��� 
���          �debito.                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJACCCD From LJATransacao
	
	Data oFormas					  //Cole��o de formas de pagamento
	
	Method New()                             //metodo construtor         
	Method GetFormaPgto(oRetTran, aFormas) //Retorna a forma de pagamento
		
EndClass                    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJACCCD.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJACCCD 
	
	_Super:New() 
	
	oFormas := NIl

Return Self       


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetFormaPgto         �Autor  �Vendas CRM      � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna as formas de pagamento                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFormaPgto(oRetorno, aFormas) Class LJACCCD 
    Local cFormPgto  := ""                          //forma de pagamento
    Local nMvLjPagto := SuperGetMv("MV_LJPAGTO",,1) //Parametro da forma de pagamento
    Local nPos 		 := 0                           //Posi��o de localiza��o
        
    
    If oRetorno <> NIl
              
	    If nMvLjPagto == 1 //Busca pelo SX5 
	    		If Len(aFormas) > 0 .AND. (	nPos := aScan(aFormas, {|f| f[1] == oRetorno:cFormaPgto}) ) > 0  
	    			cFormPgto := AllTrim(aFormas[nPos, 02])
	    		
	    		EndIf
	    		//cFormPgto := AllTrim(Tabela("24",AllTrim(oRetorno:cFormaPgto)))
	    Else 
	    	//Retorna a administradora Financeira
	    	cFormPgto := oRetorno:oRetorno:cAdmFin
	    EndIf
    
    EndIf

Return cFormPgto 