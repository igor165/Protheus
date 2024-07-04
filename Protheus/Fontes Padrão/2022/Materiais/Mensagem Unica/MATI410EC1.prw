#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TBICODE.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATI410EC1.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI410EC1
Funcao de integracao com o adapter EAI para recebimento e
envio de informaรงรตes de Vendas/Pedido Varejo (retailSales)
utilizando o conceito de mensagem unica com Objeto EAI. 
@type function
@param Caracter, cMsgRet, Variavel com conteudo para envio/recebimento.
@param Numรฉrico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author Victor Furukawa
@version P12
@since 09/06/2021
@return Array, Array contendo o resultado da execucao e a mensagem  de retorno.
		aRet[1] - (boolean) Indica o resultado da execu็ใo da fun็ใo
		aRet[2] - (caracter) Mensagem para envio
/*/
//-------------------------------------------------------------------

Function MATI410EC1(xEnt, nTypeTrans, cTypeMessage, lJSon)	

    Local lRet 		:= .T.				//Indica o resultado da execuรงรฃo da funรงรฃo
	Local cRet		:= ""				//Retorno que serรก enviado pela funรงรฃo
	Local aRet		:= {.T.,""} 		//Array de retorno da execucao da versao
         
	Default nTypeTrans		:= 3
	Default cTypeMessage	:= ""	

	If ( nTypeTrans == TRANS_RECEIVE )

		If ( cTypeMessage == EAI_MESSAGE_BUSINESS ) .Or. ( cTypeMessage == EAI_MESSAGE_RESPONSE )

			If !Empty(xEnt:getHeaderValue("Version"))			

				cVersao := StrTokArr(xEnt:getHeaderValue("Version"), ".")[1]
				  
				If cVersao == "1"
					
					aRet := MATI410EC2(xEnt, nTypeTrans, cTypeMessage )  
					
				Else
					lRet    := .F.					
					cRet := STR0001 // "A versใo da mensagem informada nใo foi implementada!"
					aRet := { lRet , cRet }
				EndIf
			Else					
				lRet := .F.
				cRet := STR0002 // "Versใo da mensagem nใo informada!"
				aRet := { lRet , cRet }
			EndIf			

		EndIf								                                   	
	
	EndIf	
	
Return {aRet[1], aRet[2], "SALESORDER"}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ 	      ณ IntegDef บ Autor ณ Alan Oliveira        บ Data ณ  08/03/18   บฑฑ
ฑฑฬอออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricao ณ Funcao de tratamento para o recebimento/envio de mensagem    บฑฑ
ฑฑบ           ณ unica de Reserva de produtos.                                บฑฑ
ฑฑฬอออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Uso       ณ LOJA704                                                บฑฑ
ฑฑศอออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IntegDef( xEnt, nTypeTrans, cTypeMessage , cVersion, cTransaction, lJSon )

    Local 	aRet := {}

    Default xEnt 			:= Nil
    Default cTypeMessage 	:= ""
    Default cVersion		:= ""
    Default cTransaction	:= ""
    Default lJSon 			:= .F.

    aRet := MATI410EC1(xEnt, nTypeTrans, cTypeMessage , lJSon)

Return aRet
