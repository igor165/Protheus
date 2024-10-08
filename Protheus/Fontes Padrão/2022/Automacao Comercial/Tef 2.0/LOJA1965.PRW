#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"


Function LOJA1965 ; Return  // "dummy" function - Internal Use

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJCFormas        �Autor�VENDAS CRM     � Data �  02/01/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Responsavel em armazenar as formas de pagamentos das        ��� 
���          �transacoes de tef.                                          ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class LJCFormas
	  

	Data cTipo   			//Tipo do  Comprovante da Tansacao
	Data cTotalizador 		// Totalizador do comprovante n�o Fiscal
	Data cFormaPgto   		//Forma de Pagamento
	Data nValor		  		//Valor do Pagamento 
	Data cChave        		//Numero de Vias
    Data cTipoTrans        	//Tipo da Transa��o TEF
	Data cChave2        	//Numero de Vias
    Data nVezes       		//Tentativas de Impress�o
    Data nVlrSaque			//Valor Saque
    Data nVlrVndcDesc		//Valor da venda com desconto TEF
    Data nVlrDescTEF		//Valor do desconto TEF
						
	
	Method New(	cTipo			,	cTotalizador	,	cFormaPgto	,	nValor			,;
				cChave			, 	cTipoTrans		,  nVezes		,  nVlrSaque		,;
				nVlrVndcDesc	,	nVlrDescTEF    										)



EndClass         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Vendas CRM       � Data �  02/01/13   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe LJCFormas       .               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametros�EXPC1  - Tipo de Comprovante 								  ���
���			 �			V - Vinculado									  ���
���			 �			R - Reduzido    								  ���
���			 �			G - Gerencial                                     ���
���          �EXPC2  - Totalizado Nao Fiscal         					  ���
���          �EXPC3  - Forma de Pagamento           					  ���
���          �EXPN4  - Valor do Pagamento              					  ��� 
���          �EXPC5  - Chave de Busca                					  ���
�������������������������������������������������������������������������͹��
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New(	cTipo			,		cTotalizador	,		cFormaPgto	,  nValor				,;
			cChave 			, 		cTipoTrans		,		nVezes 		, 	nVlrSaque			,;
			nVlrVndcDesc	, 		nVlrDescTEF													) Class LJCFormas 
  


	Default cTipo 			:= "G"  //Tipo do  Comprovante da Tansacao [ Gerencial]
	Default cTotalizador 	:= "01" // Totalizador do comprovante n�o Fiscal
	Default cFormaPgto 		:= ""   //Forma de Pagamento
	Default nValor 			:= 0		  //Valor do Pagamento 
   	Default cTipoTrans		:= ""
	Default cChave			:= cTipo + cTotalizador + cTipoTrans + cFormaPgto //Numero de Tentativas de Impress�o 
	Default nVezes			:= 0  	//Numero de Tentativas de Impress�o
	Default nVlrSaque   	:= 0	//Valor do Saque
	Default nVlrVndcDesc   	:= 0	//Valor da venda com Desconto TEF
	Default nVlrDescTEF   	:= 0	//Valor do desconto TEF


	Self:cTipo 				:= cTipo  
	Self:cTotalizador		:= cTotalizador
	Self:cFormaPgto			:= cFormaPgto
	Self:nValor				:= nValor
	Self:cChave				:= cChave
	Self:cTipoTrans			:= cTipoTrans 
	Self:cChave2			:= cTipo + cTotalizador + cTipoTrans
	Self:nVezes				:= 0
	Self:nVlrSaque			:= nVlrSaque
	Self:nVlrVndcDesc		:= nVlrVndcDesc
	Self:nVlrDescTEF		:= nVlrDescTEF

Return Self
