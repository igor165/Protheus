#INCLUDE "PROTHEUS.CH"  
#INCLUDE "MSOBJECT.CH"

Function LOJA1937 ; Return                   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLJCRetTransacaoCB บAutor  ณVENDAS CRM  บ Data ณ  29/10/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Armazena as informacoes para realizacao de uma transacao  บฑฑ 
ฑฑบ          ณutilizando TEF.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class LJCRetTransacaoCB From LJCRetTransacaoCH
    
	Data oDataVenc														//Data de vencimento do titulo/convenio - correspondente bancario
	Data oVlrOrig														//Valor original do titulo/convenio - correspondente bancario
	Data oVlrAcre														//Valor do acrescimo do titulo/convenio - correspondente bancario
	Data oVlrAbat														//Valor do abatimento do titulo/convenio - correspondente bancario
   	Data oVlrPgto														//Valor pago do titulo/convenio - correspondente bancario
   	Data dDataPgto														//Data do pagamento do titulo/convenio - correspondente bancario
	Data cCedente														//Nome do Cedente do titulo/convenio - correspondente bancario
	Data nVlrTotCB														//Valor total dos titulos/convenios pago - correspondente bancario
	Data nTipoDocCB														//Tipo do documento: 0 ' Arrecadacao, 1 ' Titulo (Ficha de compensacao), 2 ' Tributo - correspondente bancario
	Data cCodMod														//tipo da modalidade do pagamento do CB
		
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
Method New() Class LJCRetTransacaoCB 

	_Super:New()
	
	Self:oDataVenc	:= Nil
	Self:oVlrOrig	:= Nil
	Self:oVlrAcre	:= Nil
	Self:oVlrAbat	:= Nil
   	Self:oVlrPgto	:= Nil
   	Self:dDataPgto	:= CtoD("  /  /  ")
	Self:cCedente	:= ""
	Self:nVlrTotCB	:= 0
	Self:nTipoDocCB	:= 0  
	Self:cCodMod	:= ""

Return Self 