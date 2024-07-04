#Include 'Protheus.ch'
#Include 'FWAdapterEAI.ch'

/*/{Protheus.doc} PMSA200A
Fun��o para reservar o nome do fonte.

@author Mateus Gustavo de Freitas e Silva
@since 15/03/2014
@version P11
/*/
Function PMSA200A()

Return

/*/{Protheus.doc} IntegDef
Fun��o para chamar o adapter de mensagem �nica de Contrato.

@author Mateus Gustavo de Freitas e Silva
@since 15/03/2014
@version P11

@param cXML, caracter, XML da mensagem �nica para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transa��o da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return array, Array de duas posi��es sendo a primeira o resultado do processamento e a segunda o texto de resposta.
/*/

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
   Local aRet := {}

   aRet := PMSI200A(cXML, nTypeTrans, cTypeMessage)
Return aRet