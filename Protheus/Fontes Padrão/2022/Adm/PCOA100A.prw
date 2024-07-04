#include 'protheus.ch'

/*/{Protheus.doc} PCOA100A
Funcao de integracao para recebimento da
Manuten��o de Planilha Or�ament�ria utilizando o conceito de mensagem unica.

@author  Alison Kaique
@version P12.1.17
@since   25/05/2018
/*/
Function PCOA100A()
Return FwIntegDef('PCOA100A',,,, 'PCOA100A')


/*/{Protheus.doc} IntegDef
Fun��o para a intera��o com EAI

@author  Alison Kaique
@version P12.1.17
@since   25/05/2018
/*/
STATIC FUNCTION IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return PCOI100A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
