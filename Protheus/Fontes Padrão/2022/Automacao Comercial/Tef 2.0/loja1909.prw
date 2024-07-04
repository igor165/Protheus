#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1909.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "MSOBJECT.CH"

Function LOJA1909 ; Return                     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCClisitefCCCD�Autor  �VENDAS CRM     � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface para transAcao com cartao de credito e cartao de  ��� 
���          �debito utilizando CliSitef.                                 ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCClisitefCCCD From LJACCCD

	Data oTransSitef							//Objeto do tipo LJCTransClisitef
	
	Method New()

	//Metodos da interface
	Method Credito()
	Method Debito()
	Method FuncoesAdm()
	Method Confirmar()
	Method Desfazer()
    Method CupomReduz()
      
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
Method New(oCliSitef) Class LJCClisitefCCCD 

   	_Super:New()
   	
   	Self:oTransSitef := LJCTransClisitef():New(oCliSitef)  

Return Self      

/*���������������������������������������������������������������������������
���Programa  �Credito      �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Venda com cart�o de credito                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
���������������������������������������������������������������������������*/
Method Credito(oDadosTran) Class LJCClisitefCCCD
    
    Local cRestricao := "7;8;10;15;19;31;40;32;33"+SuperGetMV("MV_LJRETEF",,";29;28")
    
	Self:oTransSitef:oCliSitef:SetTrans(oDadosTran)

	//Titulo da transacao
    Self:oTransSitef:oClisitef:cTitTran := STR0001 + " - " + ; //"Cart�o de Cr�dito "   
										    Self:oTransSitef:cSimbMoeda + AllTrim(Transform(oDadosTran:nValor, "@E 999999999999.99"))

	//���������������������������������������������������������������������Ŀ
	//�   C R E D I T O 			              							|
	//�25 Cart�o de cr�dito (todas as combina��es)	                      	�
	//�26 Cart�o de cr�dito a vista	                                        �
	//�27 Cart�o de cr�dito parcelado com financiamento do estabelecimento	|
	//�28 Cart�o de cr�dito parcelado com financiamento da administradora	�
	//�29 Cart�o de cr�dito digitado	                                    �
	//�30 Cart�o de cr�dito magn�tico	                                    |
	//�34 Cart�o de Cr�dito Pr�-rata a vista	                            �
	//�35 Cart�o de Cr�dito Pr�-rata parcelada	                            |
	//�32 Cart�o Fininvest	                                              	�
	//�33 Saque com cart�o Fininvest	                                    �
	//�36 Consulta parcelas no Cart�o de Cr�dito	                        �
	//�����������������������������������������������������������������������
	
	//Tipos de Meio de Pagamento Retirado para nao ser apresentado na tela do TEF.
	If oDadosTran:nParcela > 1		//Parcelado
		//Caso parcela seja maior que 1, � Cr�dito Parcelado. Entao retira a op��o de "cr�dito a vista"
		//Durante a homologacao as restricoes exigidas sao diferentes
		If SuperGetMV("MV_LJHMTEF", ,.F.)
			cRestricao += ";34" 
		Else
			cRestricao += ";26;34" 
		EndIf
	EndIf
	
	//Inicia a transacao 
	Self:oTransSitef:oCliSitef:IniciaFunc(_CARTAO, "["+cRestricao+"]")
       
	//Trata retorno
	oDadosTran := Self:oTransSitef:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz ,oDadosTran)
	
Return oDadosTran


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Debito       �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Venda com cart�o de debito                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Debito(oDadosTran) Class LJCClisitefCCCD  
	
	Self:oTransSitef:oCliSitef:SetTrans(oDadosTran) 

	//Titulo da transacao
	Self:oTransSitef:oClisitef:cTitTran := STR0003 + " - " + ; //"Cart�o de D�bito "
                               				Self:oTransSitef:cSimbMoeda + AllTrim(Transform(oDadosTran:nValor, "@E 999999999999.99")) 

	//��������������������������������������������
	//�D E B I T O	                             �
	//�15 Cart�o de d�bito (todas as combina��es)�
	//�16 Cart�o de d�bito a vista	             �
	//�17 Cart�o de d�bito pr�-datado            �
	//�18 Cart�o de d�bito parcelado	         �
	//�19 Cart�o de d�bito CDC	                 �
	//��������������������������������������������
     
	//Inicia a transacao 
 	Self:oTransSitef:oCliSitef:IniciaFunc(_CARTAO, "[10;20;25;31;32;33;36;40]")

	//Trata retorno
	oDadosTran := Self:oTransSitef:TratarRet(oDadosTran)
				
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz ,oDadosTran)
	
Return oDadosTran

 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |FuncoesAdm   �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Realiza as funcoes Administrativas.                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FuncoesAdm(oDadosTran) Class LJCClisitefCCCD 
	
	Self:oTransSitef:oCliSitef:SetTrans(oDadosTran)
	
	//Titulo da transacao
    Self:oTransSitef:oClisitef:cTitTran := STR0006 //"Fun��es Administrativas - Gerenciais "

	//Inicia a transacao 
	Self:oTransSitef:oCliSitef:IniciaFunc(_ADMINISTRATIVA, "[31;34;35]")
    
    //Trata retorno
	oDadosTran := Self:oTransSitef:TratarRet(oDadosTran)
			
	//Guarda a transacao na colecao
	Self:oTrans:Add(oDadosTran:oRetorno:cAutoriz ,oDadosTran)

Return oDadosTran

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Confirmar    �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirmar a operacao de Venda.                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Confirmar() Class LJCClisitefCCCD 
	
	//Confirma a transacao
   	Self:oTransSitef:Confirmar(Self:oTrans)    

	//Inicializa a colecao de transacoes
	Self:InicTrans()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Desfazer     �Autor  �Vendas CRM       � Data �  29/10/09   ���
�������������������������������������������������������������������������͹��
���Desc.     �Desfaz a operacao de Venda.                                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Desfazer() Class LJCClisitefCCCD 
   	
	//Desfaz a transacao
   	Self:oTransSitef:Desfazer(Self:oTrans)
   	
	//Inicializa a colecao de transacoes
	Self:InicTrans()
   	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CupomReduz   �Autor  �Vendas CRM       � Data �  11/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Verifica se esta habilitado a impressao do cupom reduzido   ���
���          �do tef e retorna a string para impressao no rodape do       ���
���          �cupom fiscal											      ���
�������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                  	  ���
�������������������������������������������������������������������������͹��
���Parametros�															  ���
�������������������������������������������������������������������������͹��
���Retorno   �Caracter													  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CupomReduz() Class LJCClisitefCCCD

	Local cRetorno 		:= ""										//Retorno do metodo 
	Local nCount 		:= 0										//Variavel auxiliar utilizada no for
	Local lCupomRed		:= SuperGetMV("MV_LJCUPRE",,.F.)        	//Verifica se o sitef esta parametrizado para cupom reduzido
	Local nLinhas		:= 0										//Numero de linhas retornados para impressao
	Local cViaCliente	:= ""										//Auxiliar para armazenar a via do cliente de cada transacao    
	Local cDelimit 		:= CHR(10)									//Delimitador    

	If lCupomRed    
        
		//Agrupa os cupons (Via Cliente) de todas as transacoes		
		For nCount := 1 To Self:oTrans:Count()
			
			cViaCliente := Self:oTrans:Elements(nCount):oRetorno:cViaCliente

			If !Empty(cViaCliente)
				//Verifica se tem Chr 10
				If Substr(cViaCliente, Len(cViaCliente), 1) != cDelimit				
					cRetorno += cViaCliente + Chr(10)
				Else
					cRetorno += cViaCliente				
				EndIf
			EndIf    
			
			//Total de linhas dos cupons (Via Cliente) de todas as transacoes
			nLinhas += Self:oTrans:Elements(nCount):oRetorno:oViaCliente:Count()
		
		Next
		
		//Retira o delimitador do inicio da string
		If Substr(cRetorno, 1, 1) == cDelimit
			cRetorno := Substr(cRetorno, 2)
		EndIf

		//Retira o delimitador do fim da string
		If Substr(cRetorno, Len(cRetorno), 1) == cDelimit
			cRetorno := Substr(cRetorno, 1, Len(cRetorno) - 1)
		EndIf
		
		//So retorna o cupom reduzido se o numero de linhas estiver entre 1 e 8, porque 8 linhas he
		//o limite da mensagem promocional impressa no rodape do cupom fiscal
		If !(nLinhas >= 1 .AND. nLinhas <= 8)
			cRetorno := ""
		EndIf
	
	EndIf
		
Return cRetorno
