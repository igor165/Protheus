#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"


Function LOJA1963 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJCCompr         บAutorณVENDAS CRM     บ Data ณ  28/12/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณResponsavel em armazenar os comprovantes das transacoes     บฑฑ 
ฑฑบ          ณtransacoes de tef.                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class LJCCompr
	  

	Data cTipo   //Tipo do  Comprovante da Tansacao
	Data oViaCaixa	  //Via do Caixa
	Data oViaCliente	  //Via do Cliente
	Data cTipoTrans		//Tipo da Transacao 
	Data cTotalizador // Totalizador do comprovante nใo Fiscal
	Data cFormaPgto   //Forma de Pagamento
	Data nValor		  //Valor do Pagamento 
	Data nVias        //Numero de Vias
	Data nTentativas  //Numero de Tentativas de Impressใo
	Data cChave		// Chave do Cupom Fiscal     

						
	
	Method New(	cTipo,				oViaCaixa,	oViaCliente,	cTipoTrans,;
				cTotalizador,	cFormaPgto,	nValor,			nVias,;
				nTentativas		)


EndClass         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  28/12/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCCupomTEF     .               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1  - Tipo de Comprovante 								  บฑฑ
ฑฑบ			 ณ			V - Vinculado									  บฑฑ
ฑฑบ			 ณ			R - Reduzido    								  บฑฑ
ฑฑบ			 ณ			G - Gerencial                                     บฑฑ
ฑฑบ          ณEXPC2  - Via da Caixa              						  บฑฑ
ฑฑบ          ณEXPC3  - Via do Cliente           						  บฑฑ   
ฑฑบ          ณEXPN4  - Tipo de Transa็ใo TEF          					  บฑฑ
ฑฑบ          ณEXPC5  - Totalizado Nao Fiscal         					  บฑฑ
ฑฑบ          ณEXPC6  - Forma de Pagamento           					  บฑฑ
ฑฑบ          ณEXPN7  - Numero de Vias                  					  บฑฑ 
ฑฑบ          ณEXPN8  - Numero de Tentativas            					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(	cTipo,			oViaCaixa,	oViaCliente,	cTipoTrans,;
			cTotalizador,	cFormaPgto,	nValor,			nVias,;
			nTentativas		) Class LJCCompr
  


	Default cTipo 			:= "G"  //Tipo do  Comprovante da Tansacao [ Gerencial]
	Default oViaCaixa 		:= NIL	  //Via do Caixa
	Default oViaCliente 	:= NIL	  //Via do Cliente
	Default cTipoTrans 		:= ""		//Tipo da Transacao 
	Default cTotalizador 	:= "01" // Totalizador do comprovante nใo Fiscal
	Default cFormaPgto 		:= ""   //Forma de Pagamento
	Default nValor 			:= 0		  //Valor do Pagamento 
	Default nVias 			:= 1        //Numero de Vias (2  Caixa + 1 Cliente)
	Default nTentativas 	:= 0 //Numero de Tentativas de Impressใo     


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
