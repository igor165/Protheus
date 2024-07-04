#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1919.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1919 ; Return                     

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �LJCClisitefCB    �Autor  �VENDAS CRM     � Data �  19/03/10   ���
���������������������������������������������������������������������������͹��
���Desc.     �Interface para transacao de correspondente bancario           ��� 
���������������������������������������������������������������������������͹��
���Uso       � MP10                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������     
*/
Class LJCClisitefCB From LJACB

	Data oTransSitef							//Objeto do tipo LJCTransClisitef
	
	Method New()

	//Metodos da interface
	Method EfetuaPgto()
	Method Confirmar()
	Method Desfazer() 
	Method GetFormaPgto(oRetorno) //Retorna a forma de pagamento

  
EndClass       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  19/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCClisitefCB.	              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oCliSitef) Class LJCClisitefCB 

	_Super:New()
   	
   	Self:oTransSitef := LJCTransClisitef():New(oCliSitef) 

Return Self      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EfetuaPgto   �Autor  �Vendas CRM       � Data �  19/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua a pagamento do correspondente bancario.              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method EfetuaPgto(oDadosTran) Class LJCClisitefCB
    
	Self:oTransSitef:oCliSitef:SetTrans(oDadosTran)
	
	//Titulo da transacao
    Self:oTransSitef:oClisitef:cTitTran := STR0001 //"Correspondente Bancario"
                               				
	//Inicia a transacao 
	Self:oTransSitef:oCliSitef:IniciaCB("")
    
	//Trata retorno
	oDadosTran := Self:oTransSitef:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz ,oDadosTran)
	
Return oDadosTran

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Confirmar    �Autor  �Vendas CRM       � Data �  19/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirmar a operacao de correspondente bancario.            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Confirmar() Class LJCClisitefCB 
	
	//Confirma a transacao
   	Self:oTransSitef:Confirmar(Self:oTrans)    

	//Inicializa a colecao de transacoes
	Self:InicTrans()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Desfazer     �Autor  �Vendas CRM       � Data �  19/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Desfaz a operacao de correspondente bancario.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Desfazer() Class LJCClisitefCB 
   	
	//Desfaz a transacao
   	Self:oTransSitef:Desfazer(Self:oTrans)
   	
	//Inicializa a colecao de transacoes
	Self:InicTrans()
   	
Return Nil   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |GetForma     �Autor  �Vendas CRM       � Data �  19/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna da forma de pagamento do correspondente bancario    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method GetFormaPgto(oRetorno, aFormas ) Class  LJCClisitefCB 
	Local nMvLjPagto := SuperGetMv("MV_LJPAGTO",,1)  //Parametro da forma de pagamento
	Local cCodMod := ""                              //codigo do Modelo
	Local cFormPgto := ""                           //Descri��o da forma
   
    If oRetorno <> NIl                 
    
	    cCodMod :=  oRetorno:cCodMod 
	    If SubStr(cCodMod,1,2) == "00"			//Cheque
	    		cCodMod 		:= AllTrim(MVCHEQUE)
		ElseIf SubStr(cCodMod,1,2) == "01" 	//Debito
			cCodMod 		:= "CD"
		ElseIf SubStr(cCodMod,1,2) == "02" 	//Credito		
			cCodMod 		:= "CC"
		ElseIf SubStr(cCodMod,1,2) == "98" 	//Dinheiro
			cCodMod 		:= SuperGetMV("MV_SIMB1")
		Else
			//cForma 		:= "99"   
			cCodMod := SuperGetMV("MV_SIMB1")
		EndIf   

              
	    If nMvLjPagto == 1 .OR. (cCodMod $ AllTrim(MVCHEQUE) + "|" + SuperGetMV("MV_SIMB1")) //Busca pelo SX5  
	    		If Len(aFormas) > 0 .AND. (	nPos := aScan(aFormas, {|f| f[1] == cCodMod}) ) > 0  
	    			cFormPgto := AllTrim(aFormas[nPos, 02])	    		
	    		EndIf
	    	
	    	//cFormPgto := AllTrim(Tabela("24",AllTrim(cCodMod)))
	    Else 
	    	//Retorna a administradora Financeira
	    	cFormPgto := oRetorno:oRetorno:cAdmFin
	    EndIf
    
    ElseIf Self:oTransSitef:oCliSitef:oRetorno:cFormaCel <> Nil .And. Self:oTransSitef:oCliSitef:oRetorno:cFormaCel <> ""
		Do Case
			Case Self:oTransSitef:oCliSitef:oRetorno:cFormaCel == "1"
				cFormPgto	:= "R$"
			Case Self:oTransSitef:oCliSitef:oRetorno:cFormaCel == "2"
				cFormPgto	:= "CH"
		EndCase
	EndIf

Return cFormPgto

