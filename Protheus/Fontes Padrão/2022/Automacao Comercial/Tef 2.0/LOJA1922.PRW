#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1922.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1922 ; Return                     

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �LJCClisitefRC    �Autor  �VENDAS CRM     � Data �  16/03/10   ���
���������������������������������������������������������������������������͹��
���Desc.     �Interface para transacao de recarga de celular                ��� 
���������������������������������������������������������������������������͹��
���Uso       � MP10                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������     
*/
Class LJCClisitefRC From LJARecargaCelular

	Data oTransSitef							//Objeto do tipo LJCTransClisitef
	
	Method New()

	//Metodos da interface
	Method RecNFis()
	Method RecFis()
	Method Confirmar()
	Method Desfazer()
  
EndClass       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  16/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCClisitefRC.	              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oCliSitef) Class LJCClisitefRC 

	_Super:New()
   	
   	Self:oTransSitef := LJCTransClisitef():New(oCliSitef) 

Return Self      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RecNFis      �Autor  �Vendas CRM       � Data �  16/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua a recarga de celular nao fiscal.                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RecNFis(oDadosTran) Class LJCClisitefRC
    
	Self:oTransSitef:oCliSitef:SetTrans(oDadosTran)
	
	//Titulo da transacao
    Self:oTransSitef:oClisitef:cTitTran := STR0001 //"Recarga de celular n�o fiscal"
                               				
	//Inicia a transacao 
	Self:oTransSitef:oCliSitef:IniciaFunc(_RECARGANAOFISCAL, "")
    
	//Trata retorno
	oDadosTran := Self:oTransSitef:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz ,oDadosTran)
	
Return oDadosTran

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RecFis       �Autor  �Vendas CRM       � Data �  16/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua a recarga de celular fiscal, ou seja, o item eh .    ���
���          �lancado no cupom fiscal                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method RecFis(oDadosTran) Class LJCClisitefRC
    
	Self:oTransSitef:oCliSitef:SetTrans(oDadosTran)
	
	//Titulo da transacao
    Self:oTransSitef:oClisitef:cTitTran := STR0002 //"Recarga de celular fiscal"
                               				
	//Inicia a transacao 
	Self:oTransSitef:oCliSitef:IniciaFunc(_RECARGAFISCAL, "")
    
	//Trata retorno
	oDadosTran := Self:oTransSitef:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz ,oDadosTran)
	
Return oDadosTran

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Confirmar    �Autor  �Vendas CRM       � Data �  16/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirmar a operacao de recarga de celular.                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Confirmar() Class LJCClisitefRC 
	
	//Confirma a transacao
   	Self:oTransSitef:Confirmar(Self:oTrans)    

	//Inicializa a colecao de transacoes
	Self:InicTrans()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Desfazer     �Autor  �Vendas CRM       � Data �  16/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Desfaz a operacao de recarga de celular.                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Desfazer() Class LJCClisitefRC 
   	
	//Desfaz a transacao
   	Self:oTransSitef:Desfazer(Self:oTrans)
   	
	//Inicializa a colecao de transacoes
	Self:InicTrans()
   	
Return Nil
//