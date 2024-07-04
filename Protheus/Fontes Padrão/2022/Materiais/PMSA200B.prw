#Include 'Protheus.ch'
#Include 'FWAdapterEAI.ch'

/*/{Protheus.doc} PMSA200B
Fun��o utilizada no envio da mensagem InternalID.

@description
Esta fun��o � utilizada para enviar os InternalIDs alterados no Protheus
ap�s a troca de c�digo do projeto. Como o EAI impede que uma thread
acione duas mensagens �nicas a rotina � executada em uma nova thread.

@author Mateus Gustavo de Freitas e Silva
@since 15/03/2014
@version P11

@param cXML, caracter, XML da mensagem �nica para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transa��o da Mensagem. (20-Business, 21-Response, 22-Receipt)
@param cCompany, caracter, Empresa utilizada para envio da mensagem.
@param cBranch, caracter, Filial utilizada para envio da mensagem.

@return array, Array de duas posi��es sendo a primeira o resultado do processamento e a segunda o texto de resposta.
/*/
Function PMSA200B(cXML, nTypeTrans, cTypeMessage, cCompany, cBranch)
   Local aRet := {}

   RpcSetEnv(cCompany, cBranch)
   //RpcSetType(3) //Teste para n�o consumir licen�a

   aRet:= FWIntegDef("PMSA200B", cTypeMessage, nTypeTrans, cXML, "PMSA200B")

   RpcClearEnv()
Return aRet

/*/{Protheus.doc} IntegDef
Fun��o para chamar o adapter de mensagem �nica de InternalID.

@description
Esta fun��o � utilizada para enviar os InternalIDs alterados no Protheus
ap�s a troca de c�digo do projeto.

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

   aRet := PMSI200B(cXML, nTypeTrans, cTypeMessage)
Return aRet