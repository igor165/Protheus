/*/{Protheus.doc} FINA040B
Atualiza��o da situa��o bancario do t�tulo

@author   Rodrigo Machado Pontes
@version  P11
@since	  26/08/2014
/*/
Function FINA040B()

Return

/*/{Protheus.doc} IntegDef
Atualiza��o da situa��o bancario do t�tulo

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

@author   Rodrigo Machado Pontes
@version  P11
@since	  26/08/2014
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return FINI040B(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
