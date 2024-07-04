/*/{Protheus.doc} FINA050A
Fun��o para reservar o nome do fonte.

@author   Mateus Gustavo de Freitas e Silva
@version  P11
@since    25/03/2014
/*/
User Function FINA040A()

Return

/*/{Protheus.doc} IntegDef
Fun��o para chamar o adapter de mensagem �nica de substitui��o de t�tulo a receber.

@param	cXml       - XML recebido pelo EAI Protheus
		cTypeTrans - Tipo de transa��o
					"0" = TRANS_RECEIVE
					"1" = TRANS_SEND
		cTypeMsg   - Tipo da mensagem do EAI
					"20" = EAI_MESSAGE_BUSINESS
					"21" = EAI_MESSAGE_RESPONSE
					"22" = EAI_MESSAGE_RECEIPT
					"23" = EAI_MESSAGE_WHOIS
		cVersion   - Vers�o da Mensagem �nica TOTVS
		cTransac   - Nome da mensagem iniciada no adapter.

@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
			aRet[1]	(boolean) Indica o resultado da execu��o da fun��o
			aRet[2]	(caracter) Mensagem Xml para envio

@author   Mateus Gustavo de Freitas e Silva
@version  P11
@since    25/03/2014
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return FINI040A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
