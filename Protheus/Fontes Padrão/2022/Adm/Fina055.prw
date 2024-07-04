#include 'protheus.ch'

/*/{Protheus.doc} FINA055
Regra da Msg de Financimento da integra��o Tin X Protheus
Fun��o criara para suportar uma eventual cria��o de regra
de neg�cio para o processo de financiamento no Protheus.

Fonte criado para portar a IntegDef de financiamento da
integra��o Protheus X Totvs Incorpora��es e tamb�m para
suportar uma eventual cria��o de regra de neg�cio para
o processo de financiamento no Protheus.

@author  Jandir Deodato
@since   24/04/2012
/*/
Function FINA055()
Return


/*/{Protheus.doc} IntegDef
Fun��o para integra��o via Mensagem �nica Totvs.

@author  Jandir Deodato
@since   24/04/2012
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return FINI055(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
