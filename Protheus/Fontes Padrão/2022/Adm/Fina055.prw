#include 'protheus.ch'

/*/{Protheus.doc} FINA055
Regra da Msg de Financimento da integração Tin X Protheus
Função criara para suportar uma eventual criação de regra
de negócio para o processo de financiamento no Protheus.

Fonte criado para portar a IntegDef de financiamento da
integração Protheus X Totvs Incorporações e também para
suportar uma eventual criação de regra de negócio para
o processo de financiamento no Protheus.

@author  Jandir Deodato
@since   24/04/2012
/*/
Function FINA055()
Return


/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@author  Jandir Deodato
@since   24/04/2012
/*/
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return FINI055(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
