#INCLUDE "MSOBJECT.CH"
#INCLUDE "DEFTEF.CH"

Function LOJA1966 ; Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCDadosTransacaoADM บAutor  ณVendas Clientes     บ Data ณ  11/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDados da transacao administrativa									     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCDadosTransacaoCNC From LJADadosTransacao

   	
   	Data nBanco														//Numero do banco
   	Data nAgencia													//Numero da agencia
   	Data nConta														//Numero da conta
   	Data nCheque													//Numero do cheque
   	Data nC1														//C1
   	Data nC2														//C2
   	Data nC3														//C3
   	Data dDataVcto													//Data de vencimento
   	Data cTipoCli													//Tipo do Cliente
   	Data cCNPJ														//CNPJ/CGC Cliente 
   	Data cNsu														//Nsu da Transacao
   	Data dDataTrn													//Data da Transacao
   	Data cHoraTrn													//Hora da Transacao                                                                   
   	
  	   		   			
	Method New()													//Metodo construtor  
	
	
	
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew   	       บAutor  ณVendas Clientes     บ Data ณ  11/02/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe LJCDadosTransacaoCheque.	    	     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPN1 (1 - nValor) - Valor da transacao   				 		 บฑฑ
ฑฑบ			 ณEXPN2 (2 - nCupom) - Numero de identificacao da transacao   		 บฑฑ
ฑฑบ			 ณEXPD1 (3 - dData) - Data da transacao   							 บฑฑ
ฑฑบ			 ณEXPC1 (4 - cHora) - Hora da transacao				   				 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto														     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(nValor	, nCupom	, dData	, cHora		, ;
		   nBanco	, nAgencia	, nConta, nCheque	, ;
		   nC1		, nC2		, nC3	, cTipoCli	, ;
		   dDataVcto, cCNPJ		, cNsu	, cRede		, ;
		   dDataTrn	, cHoraTrn  ) Class LJCDadosTransacaoCNC
    
    _Super:New(nValor, nCupom, dData, cHora, _ADMINISTRATIVA, cRede)
	
	::nBanco		:= nBanco
   	::nAgencia		:= nAgencia
   	::nConta		:= nConta
   	::nCheque		:= nCheque
   	::nC1			:= nC1
   	::nC2			:= nC2
   	::nC3			:= nC3
   	::cTipoCli		:= cTipoCli											//Tipo do Cliente
   	::dDataVcto		:= dDataVcto
   	::cCNPJ			:= cCNPJ											//CNPJ/CGC Cliente   	
   	::cNsu			:= cNsu											//Nsu da Transacao
   	::dDataTrn		:= dDataTrn											//Data da Transacao
   	::cHoraTrn		:= cHoraTrn											//Hora da Transacao   
   	  	
Return Self