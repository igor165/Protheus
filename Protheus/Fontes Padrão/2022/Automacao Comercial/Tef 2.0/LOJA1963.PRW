#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"


Function LOJA1963 ; Return  // "dummy" function - Internal Use

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCCompr         �Autor�VENDAS CRM     � Data �  28/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em armazenar os comprovantes das transacoes     ��� 
���          �transacoes de tef.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCCompr
	  

	Data cTipo   //Tipo do  Comprovante da Tansacao
	Data oViaCaixa	  //Via do Caixa
	Data oViaCliente	  //Via do Cliente
	Data cTipoTrans		//Tipo da Transacao 
	Data cTotalizador // Totalizador do comprovante n�o Fiscal
	Data cFormaPgto   //Forma de Pagamento
	Data nValor		  //Valor do Pagamento 
	Data nVias        //Numero de Vias
	Data nTentativas  //Numero de Tentativas de Impress�o
	Data cChave		// Chave do Cupom Fiscal     

						
	
	Method New(	cTipo,				oViaCaixa,	oViaCliente,	cTipoTrans,;
				cTotalizador,	cFormaPgto,	nValor,			nVias,;
				nTentativas		)


EndClass         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  28/12/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCCupomTEF     .               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1  - Tipo de Comprovante 								  ���
���			 �			V - Vinculado									  ���
���			 �			R - Reduzido    								  ���
���			 �			G - Gerencial                                     ���
���          �EXPC2  - Via da Caixa              						  ���
���          �EXPC3  - Via do Cliente           						  ���   
���          �EXPN4  - Tipo de Transa��o TEF          					  ���
���          �EXPC5  - Totalizado Nao Fiscal         					  ���
���          �EXPC6  - Forma de Pagamento           					  ���
���          �EXPN7  - Numero de Vias                  					  ��� 
���          �EXPN8  - Numero de Tentativas            					  ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(	cTipo,			oViaCaixa,	oViaCliente,	cTipoTrans,;
			cTotalizador,	cFormaPgto,	nValor,			nVias,;
			nTentativas		) Class LJCCompr
  


	Default cTipo 			:= "G"  //Tipo do  Comprovante da Tansacao [ Gerencial]
	Default oViaCaixa 		:= NIL	  //Via do Caixa
	Default oViaCliente 	:= NIL	  //Via do Cliente
	Default cTipoTrans 		:= ""		//Tipo da Transacao 
	Default cTotalizador 	:= "01" // Totalizador do comprovante n�o Fiscal
	Default cFormaPgto 		:= ""   //Forma de Pagamento
	Default nValor 			:= 0		  //Valor do Pagamento 
	Default nVias 			:= 1        //Numero de Vias (2  Caixa + 1 Cliente)
	Default nTentativas 	:= 0 //Numero de Tentativas de Impress�o     


	Self:cTipo 				:= cTipo  
	Self:oViaCaixa 			:= oViaCaixa
	Self:oViaCliente 		:= oViaCliente
	Self:cTipoTrans	 		:= cTipoTrans
	Self:cTotalizador		:= cTotalizador
	Self:cFormaPgto			:= cFormaPgto
	Self:nValor				:= nValor
	Self:nVias				:= nVias
	Self:nTentativas		:= nTentativas    
	Self:cChave				:= cTipo + cTotalizador + cTipoTrans

Return Self
