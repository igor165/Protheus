#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFTEF.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1925.CH"

Function LOJA1925 ; Return                     

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCClisitefPbm �Autor  �VENDAS CRM     � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Interface para transacao com Pbm							  ��� 
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCClisitefPbm From LJAPbm

	Data oTransSitef							//Objeto do tipo LJCTransClisitef
	Data oPbm									//Objeto do tipo LJCPbm
	Data oConfPbms								//Objeto do tipo LJCList com as configuracoes da PBM
	Data oDadosTran								//Objeto com os dados da transacao
	
	Method New()

	//Metodos da interface
	Method IniciaVend()
	Method VendProd()
	Method CancProd()
	Method FinalVend()
	Method BuscaSubs()
	Method ConfProd()
	Method CancPbm()
	Method SelecPbm()
	Method Confirmar()
	Method Desfazer()
 	Method IniciouVen()
      
EndClass       

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(oCliSitef, oPbms) Class LJCClisitefPbm 

   	_Super:New()
   	
   	::oConfPbms := oPbms
   	
   	::oPbm := LJCPbm():Pbm()
   	
   	::oTransSitef := LJCTransClisitef():New(oCliSitef)  

Return Self      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IniciaVend   �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Venda com cart�o de credito a vista.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method IniciaVend(oDadosTran) Class LJCClisitefPbm
    
    Local lRetorno := .F.						//Retorno do metodo
    
	lRetorno := ::oPbm:IniciaVend(CVALTOCHAR(oDadosTran:nCupom), oDadosTran:cOperador)
	
	If lRetorno
		//Os dados da transacao tem que ser armazenado no atributo oDadosTrans da classe e
		//os atributos dData e cHora precisam ser alterados com os dados gerados pela PBM
		::oDadosTran := oDadosTran 
	
		::oDadosTran:dData := CTOD(SubStr(::oPbm:oPbm:cData, 7, 2) + "/" + SubStr(::oPbm:oPbm:cData, 5, 2) + "/" + SubStr(::oPbm:oPbm:cData, 1, 4))
		::oDadosTran:cHora := Substr(::oPbm:oPbm:cHora, 1, 2) + ":" + Substr(::oPbm:oPbm:cHora, 3, 2) + ":" + Substr(::oPbm:oPbm:cHora, 5, 2)
	Else
		::oPbm:oPbm := Nil
	EndIf	

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VendProd     �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Venda no produto na PBM			                          ���
�������������������������������������������������������������������������͹��
���Parametros� 1.ExpC1 - Codigo de barras do produto                      ���
���          � 2.ExpN1 - Quantidade do produto                            ���
���          � 3.ExpN2 - Preco do produto                                 ���
���          � 4.ExpN3 - Percentual de desconto do produto                ���
���          � 5.ExpL1 - Se o item foi enviado para pbm                   ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method VendProd(cCodBarra, nQtde, nPrUnit, nPercDesc, lItemPbm) Class LJCClisitefPbm 
    
	Local lRetorno := .F.						//Retorno do metodo
	
	lRetorno := ::oPbm:VendProd(cCodBarra, nQtde, nPrUnit, @nPercDesc, @lItemPbm)
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CancProd     �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cancela o produto na PBM			                          ���
�������������������������������������������������������������������������͹��
���Parametros� 1.ExpC1 - Codigo de barras do produto                      ���
���          � 2.ExpN1 - Quantidade do produto                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancProd(cCodBarra, nQtde) Class LJCClisitefPbm  
	
	Local lRetorno := .F.						//Retorno do metodo
	
	lRetorno := ::oPbm:CancProd(cCodBarra, nQtde)
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |FinalVend    �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Finaliza venda PBM				                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method FinalVend() Class LJCClisitefPbm  
	
	Local lRetorno := .F.						//Verifica se a transacao foi finalizada
	Local oDadosTran := Nil						//Retorno do metodo
	
	lRetorno := ::oPbm:FinalVend()
	
		
Return oDadosTran

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |BuscaSubs    �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Busca o valor do subsidio				                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method BuscaSubs() Class LJCClisitefPbm  

	Local nRetorno := .F.						//Retorno do metodo
		
	nRetorno := ::oPbm:BuscaSubs()

Return ::oPbm:BuscaSubs()
   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |ConfProd     �Autor  �Vendas CRM       � Data �  31/03/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirma o produto vendido no ECF                           ���
�������������������������������������������������������������������������͹��
���Parametros� 1.ExpC1 - Codigo de barras do produto                      ���
���          � 2.ExpN1 - Quantidade do produto                            ���
���          � 3.ExpL1 - Se o produto foi vendido ou nao.                 ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method ConfProd(cCodBarra, nQtde, lOK) Class LJCClisitefPbm 
	
	Local lRetorno := .F.						//Retorno do metodo
		
	lRetorno := ::oPbm:ConfProd(cCodBarra, nQtde, lOK)

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |CancPbm      �Autor  �Vendas CRM       � Data �  01/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua o cancelamento da PBM		                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method CancPbm(oDadosTran) Class LJCClisitefPbm 

	Local lRetorno := .F.						//Verifica se a transacao foi cancelada
	Local oDadosTran := Nil						//Retorno do metodo
	
	lRetorno := ::oPbm:CancPbm()
	
	If lRetorno
		//Os dados da transacao tem que ser armazenado no atributo oDadosTrans da classe e
		//os atributos dData,cHora e nCupom precisam ser alterados com os dados gerados pela PBM
		
		::oDadosTran := oDadosTran 
		
		::oDadosTran:dData 	:= CTOD(SubStr(::oPbm:oPbm:cData, 7, 2) + "/" + SubStr(::oPbm:oPbm:cData, 5, 2) + "/" + SubStr(::oPbm:oPbm:cData, 1, 4))
		::oDadosTran:cHora 	:= Substr(::oPbm:oPbm:cHora, 1, 2) + ":" + Substr(::oPbm:oPbm:cHora, 3, 2) + ":" + Substr(::oPbm:oPbm:cHora, 5, 2)
		::oDadosTran:nCupom 	:= Val(::oPbm:oPbm:cNumCupom)
	
	EndIf	
		
Return oDadosTran 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |SelecPbm     �Autor  �Vendas CRM       � Data �  01/04/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Seleciona a PBM					                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method SelecPbm() Class LJCClisitefPbm 
	
	Local lRetorno 	:= .F.			//Retorno do metodo
	Local oTelaPBM	:= Nil			//Tela da PBM
	
	If ::oConfPbms:Count() > 0 

		oTelaPBM := LJCTelaSelecao():TelaSelec(::oConfPbms:ToArray(), STR0001, STR0002)//"PBM";"Selecione a PBM"
		
		oTelaPBM:Show()
	
		If !oTelaPBM:lCancelado
			
			Do Case
				Case oTelaPBM:cRetSelect == _EPHARMA
                	::oPbm:oPbm := LJCEpharma():EPharma(::oTransSitef:oClisitef)
                	
				Case oTelaPBM:cRetSelect == _TRNCENTRE
					::oPbm:oPbm := LJCTrnCentre():TrnCentre(::oTransSitef:oClisitef) 
			EndCase
			
			lRetorno := (::oPbm:oPbm <> Nil)

		EndIf
			
	EndIf
	
Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Confirmar    �Autor  �Vendas CRM       � Data �  01/04/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Confirmar a operacao de PBM.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Confirmar() Class LJCClisitefPbm 
	
	//Confirma a transacao
   	::oTransSitef:Confirmar(::oTrans)     

	//Inicializa a colecao de transacoes
	::InicTrans()
    
	::oPbm:oPbm := Nil

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |Desfazer     �Autor  �Vendas CRM       � Data �  01/04/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Desfaz a operacao de PBM.                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method Desfazer() Class LJCClisitefPbm 

	//Desfaz a transacao
   	::oTransSitef:Desfazer(::oTrans)     
   	
	//Inicializa a colecao de transacoes
	::InicTrans()
	
	::oPbm:oPbm := Nil
   	
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |IniciouVen   �Autor  �Vendas CRM       � Data �  06/04/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna se a venda PBM foi inicializada                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method IniciouVen() Class LJCClisitefPbm
Return (::oPbm:oPbm <> Nil)