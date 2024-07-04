#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"


Function LOJA1965 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJCFormas        บAutorณVENDAS CRM     บ Data ณ  02/01/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em armazenar as formas de pagamentos das        บฑฑ 
ฑฑบ          ณtransacoes de tef.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class LJCFormas
	  

	Data cTipo   			//Tipo do  Comprovante da Tansacao
	Data cTotalizador 		// Totalizador do comprovante nใo Fiscal
	Data cFormaPgto   		//Forma de Pagamento
	Data nValor		  		//Valor do Pagamento 
	Data cChave        		//Numero de Vias
    Data cTipoTrans        	//Tipo da Transa็ใo TEF
	Data cChave2        	//Numero de Vias
    Data nVezes       		//Tentativas de Impressใo
    Data nVlrSaque			//Valor Saque
    Data nVlrVndcDesc		//Valor da venda com desconto TEF
    Data nVlrDescTEF		//Valor do desconto TEF
						
	
	Method New(	cTipo			,	cTotalizador	,	cFormaPgto	,	nValor			,;
				cChave			, 	cTipoTrans		,  nVezes		,  nVlrSaque		,;
				nVlrVndcDesc	,	nVlrDescTEF    										)



EndClass         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  02/01/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCFormas       .               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1  - Tipo de Comprovante 								  บฑฑ
ฑฑบ			 ณ			V - Vinculado									  บฑฑ
ฑฑบ			 ณ			R - Reduzido    								  บฑฑ
ฑฑบ			 ณ			G - Gerencial                                     บฑฑ
ฑฑบ          ณEXPC2  - Totalizado Nao Fiscal         					  บฑฑ
ฑฑบ          ณEXPC3  - Forma de Pagamento           					  บฑฑ
ฑฑบ          ณEXPN4  - Valor do Pagamento              					  บฑฑ 
ฑฑบ          ณEXPC5  - Chave de Busca                					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(	cTipo			,		cTotalizador	,		cFormaPgto	,  nValor				,;
			cChave 			, 		cTipoTrans		,		nVezes 		, 	nVlrSaque			,;
			nVlrVndcDesc	, 		nVlrDescTEF													) Class LJCFormas 
  


	Default cTipo 			:= "G"  //Tipo do  Comprovante da Tansacao [ Gerencial]
	Default cTotalizador 	:= "01" // Totalizador do comprovante nใo Fiscal
	Default cFormaPgto 		:= ""   //Forma de Pagamento
	Default nValor 			:= 0		  //Valor do Pagamento 
   	Default cTipoTrans		:= ""
	Default cChave			:= cTipo + cTotalizador + cTipoTrans + cFormaPgto //Numero de Tentativas de Impressใo 
	Default nVezes			:= 0  	//Numero de Tentativas de Impressใo
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
