#Include 'Protheus.ch'
#Include 'FWAdapterEAI.ch'

/*/{Protheus.doc} PMSA200B
Função utilizada no envio da mensagem InternalID.

@description
Esta função é utilizada para enviar os InternalIDs alterados no Protheus
após a troca de código do projeto. Como o EAI impede que uma thread
acione duas mensagens únicas a rotina é executada em uma nova thread.

@author Mateus Gustavo de Freitas e Silva
@since 15/03/2014
@version P11

@param cXML, caracter, XML da mensagem única para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transação da Mensagem. (20-Business, 21-Response, 22-Receipt)
@param cCompany, caracter, Empresa utilizada para envio da mensagem.
@param cBranch, caracter, Filial utilizada para envio da mensagem.

@return array, Array de duas posições sendo a primeira o resultado do processamento e a segunda o texto de resposta.
/*/
Function PMSA200B(cXML, nTypeTrans, cTypeMessage, cCompany, cBranch)
   Local aRet := {}

   RpcSetEnv(cCompany, cBranch)
   //RpcSetType(3) //Teste para não consumir licença

   aRet:= FWIntegDef("PMSA200B", cTypeMessage, nTypeTrans, cXML, "PMSA200B")

   RpcClearEnv()
Return aRet

/*/{Protheus.doc} IntegDef
Função para chamar o adapter de mensagem única de InternalID.

@description
Esta função é utilizada para enviar os InternalIDs alterados no Protheus
após a troca de código do projeto.

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

   aRet := PMSI200B(cXML, nTypeTrans, cTypeMessage)
Return aRet