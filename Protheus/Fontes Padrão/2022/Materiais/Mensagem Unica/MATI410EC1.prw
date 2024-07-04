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
envio de informações de Vendas/Pedido Varejo (retailSales)
utilizando o conceito de mensagem unica com Objeto EAI. 
@type function
@param Caracter, cMsgRet, Variavel com conteudo para envio/recebimento.
@param Numérico, nTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param Caracter, cTypeMessage, Tipo de mensagem. (Business Type, WhoIs, etc)

@author Victor Furukawa
@version P12
@since 09/06/2021
@return Array, Array contendo o resultado da execucao e a mensagem  de retorno.
		aRet[1] - (boolean) Indica o resultado da execu��o da fun��o
		aRet[2] - (caracter) Mensagem para envio
/*/
//-------------------------------------------------------------------

Function MATI410EC1(xEnt, nTypeTrans, cTypeMessage, lJSon)	

    Local lRet 		:= .T.				//Indica o resultado da execução da função
	Local cRet		:= ""				//Retorno que será enviado pela função
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
					cRet := STR0001 // "A vers�o da mensagem informada n�o foi implementada!"
					aRet := { lRet , cRet }
				EndIf
			Else					
				lRet := .F.
				cRet := STR0002 // "Vers�o da mensagem n�o informada!"
				aRet := { lRet , cRet }
			EndIf			

		EndIf								                                   	
	
	EndIf	
	
Return {aRet[1], aRet[2], "SALESORDER"}

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
��� 	      � IntegDef � Autor � Alan Oliveira        � Data �  08/03/18   ���
����������������������������������������������������������������������������͹��
��� Descricao � Funcao de tratamento para o recebimento/envio de mensagem    ���
���           � unica de Reserva de produtos.                                ���
����������������������������������������������������������������������������͹��
��� Uso       � LOJA704                                                ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
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
