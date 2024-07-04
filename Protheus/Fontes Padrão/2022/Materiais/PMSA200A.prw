#Include 'Protheus.ch'
#Include 'FWAdapterEAI.ch'

/*/{Protheus.doc} PMSA200A
Função para reservar o nome do fonte.

@author Mateus Gustavo de Freitas e Silva
@since 15/03/2014
@version P11
/*/
Function PMSA200A()

Return

/*/{Protheus.doc} IntegDef
Função para chamar o adapter de mensagem única de Contrato.

@author Mateus Gustavo de Freitas e Silva
@since 15/03/2014
@version P11

@param cXML, caracter, XML da mensagem única para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transação da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return array, Array de duas posições sendo a primeira o resultado do processamento e a segunda o texto de resposta.
/*/

Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
   Local aRet := {}

   aRet := PMSI200A(cXML, nTypeTrans, cTypeMessage)
Return aRet