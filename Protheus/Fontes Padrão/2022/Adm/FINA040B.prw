/*/{Protheus.doc} FINA040B
Atualização da situação bancario do título

@author   Rodrigo Machado Pontes
@version  P11
@since	  26/08/2014
/*/
Function FINA040B()

Return

/*/{Protheus.doc} IntegDef
Atualização da situação bancario do título

@param	cXml       - XML recebido pelo EAI Protheus
		cTypeTrans - Tipo de transação
					"0" = TRANS_RECEIVE
					"1" = TRANS_SEND
		cTypeMsg   - Tipo da mensagem do EAI
					"20" = EAI_MESSAGE_BUSINESS
					"21" = EAI_MESSAGE_RESPONSE
					"22" = EAI_MESSAGE_RECEIPT
					"23" = EAI_MESSAGE_WHOIS
		cVersion   - Versão da Mensagem Única TOTVS
		cTransac   - Nome da mensagem iniciada no adapter.

@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
			aRet[1]	(boolean) Indica o resultado da execução da função
			aRet[2]	(caracter) Mensagem Xml para envio

@author   Rodrigo Machado Pontes
@version  P11
@since	  26/08/2014
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return FINI040B(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
