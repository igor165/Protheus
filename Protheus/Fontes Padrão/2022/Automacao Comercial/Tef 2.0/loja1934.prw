#INCLUDE "PROTHEUS.CH"

Function LOJA1934 ; Return                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJARetTransacaoTefบAutor  ณVENDAS CRM  บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Armazena as informacoes para realizacao de uma transacao  บฑฑ 
ฑฑบ          ณutilizando TEF.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class LJARetTransacaoTef
	
	Data oViaCaixa
	Data oViaCliente
	Data cViaCaixa
	Data cViaCliente
	Data lTransOk
	Data dData
	Data cHora
	Data cAutoriz
	Data cNsu
	Data cId
	Data cFinalizacao 
	Data cRede 
	Data cDocCanc
	Data dDataCanc
	Data cNsuAutor	
	Data aAdmin
	Data nVlrSaque
	Data nVlrVndcDesc
	Data nVlrDescTEF
	Data nParcs 
	Data cCelular 
	Data cIdtransaction													//ID da Transa็ใo
	Data cProcessorTransactionId										//ID da transa็ใo do processador
	Data cExternalTransactionId											//ID da transa็ใo Externa
	Data cErrorReason													//Razใo do erro

	Method New()

EndClass                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas CRM       บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class LJARetTransacaoTef 

	Self:oViaCaixa					:= Nil
	Self:oViaCliente				:= Nil
	Self:cViaCaixa					:= ""
	Self:cViaCliente				:= ""
	Self:lTransOk					:= .F.
	Self:dData						:= Date()
	Self:cHora						:= Time()
	Self:cAutoriz					:= ""
	Self:cNsu						:= ""
	Self:cId						:= ""
	Self:cFinalizacao				:= ""
	Self:cRede						:= ""   
	Self:cNsuAutor      			:= ""
	Self:cDocCanc       			:= ""
	Self:dDataCanc      			:= "" 
	Self:aAdmin						:= {}
	Self:nVlrSaque					:= 0
	Self:nVlrVndcDesc				:= 0
	Self:nVlrDescTEF				:= 0
	Self:nParcs						:= 0
	Self:cCelular					:= ""
	Self:cIdtransaction				:= ""
	Self:cProcessorTransactionId	:= ""
	Self:cExternalTransactionId		:= ""
	Self:cErrorReason				:= ""
	
Return Self 
